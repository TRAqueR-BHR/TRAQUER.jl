function InfectiousStatusCtrl.generateSuspicionStatusesFromAnalyses(
    patient::Patient,
    forAnalysesRequestsBetween::Tuple{ZonedDateTime, ZonedDateTime},
    dbconn::LibPQ.Connection
)

    # TODO: Factorize with InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses

    queryString = "
        SELECT ar.*
        FROM analysis_result ar
        INNER JOIN patient p
          ON p.id  = ar.patient_id
        WHERE p.id = \$1
        AND ar.request_time >= \$2
        AND ar.request_time <= \$3
        AND ar.result = 'suspicion'"

    queryArgs  = [
        patient.id,
        first(forAnalysesRequestsBetween),
        last(forAnalysesRequestsBetween),
    ]

    try
        analysesResults = PostgresORM.execute_query_and_handle_result(
            queryString,
            AnalysisResult,
            queryArgs,
            false, # complex props
            dbconn)

        for analysisRes in analysesResults

            infectiousAgent = TRAQUERUtil.analysisRequestType2InfectiousAgentCategory(
                analysisRes.requestType
            )

            # Upsert
            infectiousStatus = InfectiousStatus(
                patient = analysisRes.patient,
                infectiousAgent = infectiousAgent,
                infectiousStatus = InfectiousStatusType.suspicion,
                refTime = analysisRes.requestTime,
                isConfirmed = false,
            )

            # Check if we already have a suspicion infectious status at that date, if yes
            # set the updatedRefTime
            statusJustBefore = InfectiousStatusCtrl.getInfectiousStatusAtTime(
                analysisRes.patient,
                infectiousStatus.infectiousAgent,
                infectiousStatus.refTime - Second(1), # We want the infectious status just
                                                      #  before the infectious status that
                                                      #  we could potentially create
                false, # retrieveComplexProps::Bool,
                dbconn
            )

            if !ismissing(statusJustBefore)
                if statusJustBefore.infectiousStatus == InfectiousStatusType.suspicion

                    # Use the refTime to set the updatedRefTime
                    infectiousStatus.updatedRefTime =  infectiousStatus.refTime

                    # Set the property so that the upsert function does an update
                    infectiousStatus.refTime = statusJustBefore.refTime
                    infectiousStatus.id = statusJustBefore.id

                end
            end

            InfectiousStatusCtrl.upsert!(infectiousStatus, dbconn)

        end

        # As always, refresh the current status of the patient
        InfectiousStatusCtrl.updateCurrentStatus(patient, dbconn)

    catch e
        rethrow(e)
    end

end

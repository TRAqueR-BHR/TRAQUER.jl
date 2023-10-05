function InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses(
    patient::Patient,
    forAnalysesRequestsBetween::Tuple{ZonedDateTime, ZonedDateTime},
    dbconn::LibPQ.Connection
)

    queryString = "
        SELECT ar.*
        FROM analysis_result ar
        INNER JOIN patient p
          ON p.id  = ar.patient_id
        WHERE p.id = \$1
        AND ar.request_time >= \$2
        AND ar.request_time <= \$3
        AND ar.result = 'positive'"

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

            @info "analysisRes.requestTime[$(analysisRes.requestTime)]"

            infectiousAgent = TRAQUERUtil.analysisRequestType2InfectiousAgentCategory(
                analysisRes.requestType
            )

            # Upsert
            infectiousStatus = InfectiousStatus(
                patient = analysisRes.patient,
                infectiousAgent = infectiousAgent,
                infectiousStatus = InfectiousStatusType.carrier,
                refTime = analysisRes.requestTime,
                isConfirmed = false,
            )

            # Check if we already have a carrier infectious status at that date, if yes
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
                if statusJustBefore.infectiousStatus == InfectiousStatusType.carrier

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

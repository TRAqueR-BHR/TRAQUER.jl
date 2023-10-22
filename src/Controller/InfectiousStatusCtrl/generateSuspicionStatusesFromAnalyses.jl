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

            # Check that the patient is not already a carrier for this infectious agent,
            #   i.e. That the status just before it (<=) is not a carrier
            # Eg.
            #
            # Existing statuses:     🍎
            # New contact status:             🥜
            # Insert new contact?:          false
            #
            # Existing statuses:              🍎
            # New contact status:             🥜
            # Insert new contact?:          false
            #
            # Existing statuses:                     🍎o
            # New contact status:             🥜
            # Insert new contact?:           true

            # Existing statuses:      🥜
            # New contact status:             🥜
            # Insert new contact?:           false (but update existing contact status)

            # Existing statuses:      🍏
            # New contact status:             🥜
            # Insert new contact?:           true

            statusJustBefore = InfectiousStatusCtrl.getInfectiousStatusAtTime(
                infectiousStatus.patient,
                infectiousStatus.infectiousAgent,
                infectiousStatus.refTime - Second(1), # We want the infectious status just
                                                            #  before the infectious status that
                                                            #  we could potentially create,
                false, # retrieveComplexProps::Bool,
                dbconn
            )

            if !ismissing(statusJustBefore)
                if statusJustBefore.infectiousStatus ∈ [InfectiousStatusType.carrier]
                    continue

                #  If a suspicion status already existed then just update the last ref. time
                elseif statusJustBefore.infectiousStatus == InfectiousStatusType.suspicion

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

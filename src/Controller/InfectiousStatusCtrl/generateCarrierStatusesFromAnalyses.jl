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
            InfectiousStatusCtrl.upsert!(infectiousStatus, dbconn)

        end

        # As always, refresh the current status of the patient
        InfectiousStatusCtrl.updateCurrentStatus(patient, dbconn)

    catch e
        rethrow(e)
    end

end

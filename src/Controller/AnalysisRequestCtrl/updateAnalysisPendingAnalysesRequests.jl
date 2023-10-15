function AnalysisRequestCtrl.updateAnalysisPendingAnalysesRequests(
    analysisResults::Vector{AnalysisResult},
    dbconn::LibPQ.Connection
)

    pendingRequests = "
        SELECT ar.*
        FROM analysis_request ar
        WHERE ar.unit_expected_collection_time < \$1
        AND ar.status != 'done' -- pending can be either 'requested' or 'in_progress'
        AND ar.request_time > \$2 -- ignore the very old requests (for performance)
        " |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            AnalysisRequest,
            [now(getTimeZone()),now(getTimeZone()) - Week(2)],
            false,
            dbconn)

    for pendingRequest in pendingRequests
        analysesResults = filter(
            res -> res.patient.id ==  pendingRequest.patient.id
                && res.requestType == pendingRequest.requestType
                # The request time recorded by the hospital should be around the same time
                # as the AnalyisRequest.requestTime
                && res.requestTime >= pendingRequest.requestTime - Hour(1)
                && res.requestTime < pendingRequest.requestTime + Hour(24), # TODO, check that delay
            analysisResults
        )
        if isempty(analysesResults)
            continue
        end

        analysisResult = first(analysesResults) # take the first for lack of better idea

        # If there is an analysisResult that the result is empty
        if ismissing(analysisResult.result)
            pendingRequest.status = AnalysisRequestStatusType.in_progress
        else
            pendingRequest.status = AnalysisRequestStatusType.done
        end

        PostgresORM.update_entity!(pendingRequest, dbconn)

    end


end

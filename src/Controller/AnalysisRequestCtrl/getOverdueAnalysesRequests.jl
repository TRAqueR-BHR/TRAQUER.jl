function AnalysisRequestCtrl.getOverdueAnalysesRequests(dbconn::LibPQ.Connection)::Vector{AnalysisRequest}

    overdueRequests = "
        SELECT ar.*
        FROM analysis_request ar
        WHERE ar.unit_expected_collection_time < \$1
        AND ar.status = 'requested'
        AND ar.request_time > \$2 -- ignore the very old requests (for performance)
        " |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            AnalysisRequest,
            [now(getTimeZone()),now(getTimeZone()) - Week(2)],
            false,
            dbconn)

    return overdueRequests

end

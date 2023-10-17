function AnalysisResultCtrl.getLastNegativeResultWithinPeriod(
    patient::Patient,
    infectiousAgent::INFECTIOUS_AGENT_CATEGORY,
    lowerBound::ZonedDateTime,
    upperBound::ZonedDateTime,
    dbconn::LibPQ.Connection
)::Union{AnalysisResult,Missing}

    results = "
        SELECT ar.*
        FROM analysis_result ar
        WHERE ar.patient_id = \$1
          AND ar.request_type = ANY(\$2)
          AND ar.request_time > \$3
          AND ar.request_time < \$4
        ORDER BY ar.request_time DESC" |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            AnalysisResult,
            [
                patient.id,
                TRAQUERUtil.infectiousAgentCategory2AnalysisRequestTypes(
                    infectiousAgent
                ),
                lowerBound,
                upperBound
            ],
            false,
            dbconn
        )

    if isempty(results)
        return missing
    else
        return first(results)
    end


end

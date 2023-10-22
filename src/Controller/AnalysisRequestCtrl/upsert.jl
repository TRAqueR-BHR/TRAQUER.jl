function AnalysisRequestCtrl.upsert!(
    analysisRequest::AnalysisRequest,
    dbconn::LibPQ.Connection
)::AnalysisRequest

    if ismissing(analysisRequest.unit)
        error("Property AnalysisRequest.unit is required")
    end
    if ismissing(analysisRequest.requestType)
        error("Property AnalysisRequest.requestType is required")
    end
    if ismissing(analysisRequest.requestTime)
        error("Property AnalysisRequest.requestTime is required")
    end

    objectFilter = if ismissing(analysisRequest.id)
        AnalysisRequest(
            unit = Unit(id = analysisRequest.unit.id),
            requestType = analysisRequest.requestType,
            requestTime = analysisRequest.requestTime
        )
    else
        AnalysisRequest(id = analysisRequest.id)
    end

    existingRequest = PostgresORM.retrieve_one_entity(
        objectFilter,
        false,
        dbconn
    )

    if ismissing(existingRequest)
        @warn "Create new"
        PostgresORM.create_entity!(
            analysisRequest,
            dbconn
        )
    else
        analysisRequest.id = existingRequest.id
        PostgresORM.update_entity!(analysisRequest,dbconn)
    end

    return analysisRequest

end

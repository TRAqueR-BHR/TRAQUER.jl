function EventRequiringAttentionCtrl.createAnalysisLateEvent(
    analysisRequest::AnalysisRequest,
    dbconn::LibPQ.Connection
)::Union{Missing,EventRequiringAttention}

    infectiousAgent = TRAQUERUtil.analysisRequestType2InfectiousAgentCategory(
        analysisRequest.requestType
    )

    infectiousStatus = InfectiousStatusCtrl.getInfectiousStatusAtTime(
        analysisRequest.patient,
        infectiousAgent,
        analysisRequest.creationTime,
        false, # retrieveComplexProps::Bool,
        dbconn
    )

    if ismissing(infectiousStatus)
        @warn (
            "Unable to find an infectious status for patient[$(patient.id)], "
            *"infectiousAgent[$infectiousAgent], refTime[$(analysisRequest.creationTime)]"
        )
        return missing
    end

    eventRequiringAttention = EventRequiringAttention(
        infectiousStatus = infectiousStatus,
        isPending = true,
        eventType = EventRequiringAttentionType.analysis_late,
        refTime = analysisRequest.unitExpectedCollectionTime
    )
    EventRequiringAttentionCtrl.upsert!(eventRequiringAttention, dbconn)

    return eventRequiringAttention

end

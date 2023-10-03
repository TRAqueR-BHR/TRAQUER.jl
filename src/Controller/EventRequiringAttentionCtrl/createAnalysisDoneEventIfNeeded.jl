function EventRequiringAttentionCtrl.createAnalysisDoneEventIfNeeded(
    analysis::AnalysisResult,
    dbconn::LibPQ.Connection
)::Union{EventRequiringAttention, Nothing}

    if ismissing(analysis.result)
        return
    end

    # If there is already a status for the same infectious agent and same time, then no
    # need to create an event.
    # Reminder: InfectiousStatus.refTime coincide with AnalysisResult.requestTime
    infectiousAgent = TRAQUERUtil.analysisRequestType2InfectiousAgentCategory(
        analysis.requestType
    )

    infectiousStatusAtExactSameTime::Bool =
    "
    SELECT ist.id
    FROM infectious_status ist
    WHERE ist.patient_id = \$1
    AND ist.infectious_agent = \$2
    AND ist.ref_time = \$3" |>
    n -> PostgresORM.execute_plain_query(
        n,
        [analysis.patient.id, infectiousAgent, analysis.requestTime],
        dbconn
    ) |> n -> if isempty(n) false else true end

    if infectiousStatusAtExactSameTime
        return
    end

    # We want to know the status a few seconds before the analysis request to make sure
    #  we dont get a status that coincide with the analysis request which would lead to
    #  the creation of an event that brings the same information. Typical case where we want
    #  to have an event is when a 'contact' or 'carrier' gets its first negative analysis
    timeOfInterest = analysis.requestTime - Second(2)

    statusAtTime = InfectiousStatusCtrl.getInfectiousStatusAtTime(
        analysis.patient,
        infectiousAgent,
        timeOfInterest,
        true, # retrieveComplexProps::Bool,
        dbconn
    )

    # If there is no infectious status at the time of the analysis request, or that the
    # infectious status is not at risk, do not create an event
    if isMissingOrNothing(statusAtTime) || statusAtTime == InfectiousStatusType.not_at_risk
        return
    else

        # Create the event for the new analysis result
        # NOTE: We always want the users to know that a result has arrived
        eventRequiringAttention = EventRequiringAttention(
            infectiousStatus = statusAtTime,
            isPending = true,
            eventType = EventRequiringAttentionType.analysis_done,
            refTime = analysis.requestTime
        )

        EventRequiringAttentionCtrl.upsert!(eventRequiringAttention, dbconn)
    end



    return eventRequiringAttention

end

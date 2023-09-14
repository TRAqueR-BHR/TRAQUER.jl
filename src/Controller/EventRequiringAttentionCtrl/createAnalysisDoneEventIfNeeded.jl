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
    #  the creation of an event that brings the same information
    timeOfInterest = analysis.requestTime - Second(2)

    statusAtTime = InfectiousStatusCtrl.getInfectiousStatusAtTime(
        analysis.patient,
        infectiousAgent,
        timeOfInterest,
        true, # retrieveComplexProps::Bool,
        dbconn
    )

    # If there is no infectious status at the time of the analysis request, create one
    # as 'not_at_risk'
    # Reminder: An event must be related to an infectious status, by convention and because
    #            how of the INNER JOIN in `getInfectiousStatusForListing`
    @info "statusAtTime" statusAtTime
    if isMissingOrNothing(statusAtTime)
        @warn (
            "No infectious status found for patient[$(analysis.patient.id)] at "
            * "time[($(analysis.requestTime))] => Create a 'not_at_risk' event to attach to it"
        )
        statusAtTime = InfectiousStatus(
            patient = analysis.patient,
            infectiousAgent = infectiousAgent,
            infectiousStatus = InfectiousStatusType.not_at_risk,
            refTime = analysis.requestTime - Minute(1),
            isConfirmed = true,
        )
        InfectiousStatusCtrl.upsert!(
            statusAtTime,
            dbconn
            ;createEventForStatus = false
        )

        # As always, refresh the current status of the patient
        InfectiousStatusCtrl.updateCurrentStatus(analysis.patient, dbconn)

    end

    eventRequiringAttention = EventRequiringAttention(
            infectiousStatus = statusAtTime,
            isPending = true,
            eventType = EventRequiringAttentionType.analysis_done,
            refTime = analysis.requestTime
    )

    EventRequiringAttentionCtrl.upsert!(eventRequiringAttention, dbconn)

    return eventRequiringAttention

end

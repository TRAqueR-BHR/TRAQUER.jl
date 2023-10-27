function EventRequiringAttentionCtrl.requiresTeamNotification(
    evt::EventRequiringAttention,
    dbconn::LibPQ.Connection
)::Bool

    # Some event types dont require notification
    if evt.eventType ∈ [
        EventRequiringAttentionType.analysis_in_progress,
        EventRequiringAttentionType.analysis_done,
        EventRequiringAttentionType.death,
    ]
        return false
    end

    # Exclude the events for new infectious status that are not carrier or at risk
    if evt.eventType == EventRequiringAttentionType.new_status
        if evt.infectiousStatus.infectiousStatus ∉ [InfectiousStatusType.carrier, InfectiousStatusType.suspicion]
            return false
        end
    end

    return true

end

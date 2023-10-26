function EventRequiringAttentionCtrl.requiresTeamNotification(
    evt::EventRequiringAttention,
    dbconn::LibPQ.Connection
)::Bool

    if evt.eventType ∈ [
        EventRequiringAttentionType.analysis_in_progress,
        EventRequiringAttentionType.death,
    ]
        return false
    end

    return true

end

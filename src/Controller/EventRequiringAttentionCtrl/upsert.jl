function EventRequiringAttentionCtrl.upsert!(
    eventRequiringAttention::EventRequiringAttention, dbconn::LibPQ.Connection
)::EventRequiringAttention

    # Check whether an event already exists
    filterObject = EventRequiringAttention(
        infectiousStatus = eventRequiringAttention.infectiousStatus,
        refTime = eventRequiringAttention.refTime,
        eventType = eventRequiringAttention.eventType,
    )

    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)

    if ismissing(existing)
        if ismissing(eventRequiringAttention.creationTime)
            eventRequiringAttention.creationTime = now(getTimeZone())
        end
        if ismissing(eventRequiringAttention.isNotificationSent)
            eventRequiringAttention.isNotificationSent = false
        end

        PostgresORM.create_entity!(eventRequiringAttention,dbconn)
    else
        eventRequiringAttention.id = existing.id
        PostgresORM.update_entity!(eventRequiringAttention,dbconn)
    end

end

function EventRequiringAttentionCtrl.upsert!(
    eventRequiringAttention::EventRequiringAttention, dbconn::LibPQ.Connection
)

    # Check whether an infectious status
    filterObject = EventRequiringAttention(
        infectiousStatus = eventRequiringAttention.infectiousStatus,
        refTime = eventRequiringAttention.refTime,
        eventType = eventRequiringAttention.eventType,
    )
    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)

    if ismissing(existing)
        PostgresORM.create_entity!(eventRequiringAttention,dbconn)
    else
        eventRequiringAttention.id = existing.id
        PostgresORM.update_entity!(eventRequiringAttention,dbconn)
    end

end

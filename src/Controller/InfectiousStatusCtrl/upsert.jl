function InfectiousStatusCtrl.upsert!(infectiousStatus::InfectiousStatus, dbconn::LibPQ.Connection)

    # Check whether an infectious status
    filterObject = InfectiousStatus(
        patient = infectiousStatus.patient,
        refTime = infectiousStatus.refTime,
        infectiousAgent = infectiousStatus.infectiousAgent,
        infectiousStatus = infectiousStatus.infectiousStatus,
    )
    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)
    if ismissing(existing)

        # Create the infectious
        PostgresORM.create_entity!(infectiousStatus,dbconn)

        # Create the event requiring attention
        eventRequiringAttention = EventRequiringAttention(
            infectiousStatus = infectiousStatus,
            is_pending = true,
            eventType = EventRequiringAttentionType.new_status,
            refTime = infectiousStatus.refTime
        )
        EventRequiringAttentionCtrl.upsert!(eventRequiringAttention, dbconn)

    else
        infectiousStatus.id = existing.id
        PostgresORM.update_entity!(infectiousStatus,dbconn)
    end

end

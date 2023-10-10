function InfectiousStatusCtrl.upsert!(
    infectiousStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
    ;createEventForStatus::Bool = true
)

    # Check whether an infectious status already exists
    filterObject = if ismissing(infectiousStatus.id)
        InfectiousStatus(
            patient = infectiousStatus.patient,
            refTime = infectiousStatus.refTime,
            infectiousAgent = infectiousStatus.infectiousAgent,
            infectiousStatus = infectiousStatus.infectiousStatus,
        )
    else
        InfectiousStatus(id = infectiousStatus.id)
    end

    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)

    # If new infectious status
    if ismissing(existing)

        # Create the infectious
        PostgresORM.create_entity!(infectiousStatus,dbconn)

        if createEventForStatus
            # Create the event requiring attention
            eventRequiringAttention = EventRequiringAttention(
                infectiousStatus = infectiousStatus,
                isPending = true,
                eventType = EventRequiringAttentionType.new_status,
                refTime = infectiousStatus.refTime
            )
            EventRequiringAttentionCtrl.upsert!(eventRequiringAttention, dbconn)
        end
    else
        infectiousStatus.id = existing.id
        PostgresORM.update_entity!(infectiousStatus,dbconn)
    end

end


function InfectiousStatusCtrl.upsert!(asso::OutbreakInfectiousStatusAsso, dbconn::LibPQ.Connection)

    if any(ismissing.([asso.outbreak, asso.infectiousStatus]))
        @warn "OutbreakInfectiousStatusAsso is missing its outbreak or infectiousStatus"
        return asso
    end

    # Check whether an existing OutbreakInfectiousStatusAsso
    filterObject = OutbreakInfectiousStatusAsso(
        outbreak = asso.outbreak,
        infectiousStatus = asso.infectiousStatus,
    )
    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)
    if ismissing(existing)

        # Create the instance
        PostgresORM.create_entity!(asso,dbconn)
    else
        asso.id = existing.id
        PostgresORM.update_entity!(asso,dbconn)
    end

end

function OutbreakUnitAssoCtrl.upsert!(asso::OutbreakUnitAsso, dbconn::LibPQ.Connection)

    # Check whether an exposure already exists,
    # Reminder: we want only one association between a unit and an outbreak
    filterObject = OutbreakUnitAsso(
        outbreak = asso.outbreak,
        unit = asso.unit
    )
    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)
    if ismissing(existing)
        PostgresORM.create_entity!(asso,dbconn)
    else
        asso.id =  existing.id

        # Dont want to erase by mistake the sameRoomOnly attribute
        if ismissing(asso.sameRoomOnly)
            asso.sameRoomOnly = existing.sameRoomOnly
        end

        # Dont want to erase by mistake the sameSectorOnly attribute
        if ismissing(asso.sameSectorOnly)
            asso.sameSectorOnly = existing.sameSectorOnly
        end

        PostgresORM.update_entity!(asso,dbconn)

    end

end

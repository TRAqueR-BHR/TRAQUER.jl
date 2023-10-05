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
        PostgresORM.update_entity!(asso,dbconn)
    end

end

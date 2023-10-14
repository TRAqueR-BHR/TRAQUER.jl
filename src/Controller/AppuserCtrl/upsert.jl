function AppuserCtrl.upsert!(role::Role, dbconn::LibPQ.Connection)

    # Check whether a role already exists
    filterObject = Role(
        codeName = role.codeName,
    )
    existing = PostgresORM.retrieve_one_entity(filterObject, false, dbconn)
    if ismissing(existing)
        PostgresORM.create_entity!(role,dbconn)
    else
        role.id = existing.id
        PostgresORM.update_entity!(role,dbconn)
    end

    return role

end

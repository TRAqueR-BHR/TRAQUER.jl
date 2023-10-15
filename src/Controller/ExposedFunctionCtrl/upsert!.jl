function ExposedFunctionCtrl.upsert!(
    exposedFunction::ExposedFunction,
    dbconn::LibPQ.Connection
)

    filterEntity = ExposedFunction(
        prettyName = exposedFunction.prettyName
    )
    existing = PostgresORM.retrieve_one_entity(filterEntity, false, dbconn)

    if ismissing(existing)
        PostgresORM.create_entity!(exposedFunction, dbconn)
    else
        exposedFunction.id = existing.id
        PostgresORM.update_entity!(exposedFunction, dbconn)
    end

end

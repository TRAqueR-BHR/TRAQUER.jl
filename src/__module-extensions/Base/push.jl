"""
    Base.push!(df::DataFrame, entity::PostgresORM.IEntity, dbconn::LibPQ.Connection)

Pushes a PostgresORM IEntity in a dataframe
"""
function Base.push!(df::DataFrame, entity::PostgresORM.IEntity, dbconn::LibPQ.Connection)

    entityAsNamedTuple = entity |>
        n -> PostgresORM.Controller.util_get_entity_props_for_db_actions(
            n,
            dbconn,
            true # Include missing values
        ) |>
        PostgresORM.PostgresORMUtil.dict2namedtuple

    push!(df, entityAsNamedTuple ;promote = true)

end

function UnitCtrl.retrieveOneUnit(
    unitCodeName::AbstractString,
    dbconn::LibPQ.Connection
)

    unit::Union{Missing,Unit} =
        PostgresORM.retrieve_one_entity(Unit(codeName = unitCodeName),
                                        false, # complex props
                                        dbconn)
    return unit

end

function UnitCtrl.createUnit(unitCodeName::AbstractString,
                             unitName::AbstractString,
                             dbconn::LibPQ.Connection)

    unit = Unit(name = unitName,
                codeName = unitCodeName)
    unit = PostgresORM.create_entity!(unit,dbconn)
    return unit

end

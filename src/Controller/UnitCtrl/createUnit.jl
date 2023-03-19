function UnitCtrl.createUnit(unitCodeName::String,
                             unitName::String,
                             dbconn::LibPQ.Connection)

    unit = Unit(name = unitName,
                codeName = unitCodeName)
    unit = PostgresORM.create_entity!(unit,dbconn)
    return unit

end

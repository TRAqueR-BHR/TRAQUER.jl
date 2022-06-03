function UnitCtrl.createUnitIfNotExists(unitCodeName::String,
                                       unitName::String,
                                       dbconn::LibPQ.Connection)

    # Look for a Unit
    unit::Union{Missing,Unit} =
        UnitCtrl.retrieveOneUnit(unitCodeName,dbconn)

    # Create unit if missing
    if ismissing(unit)
        unit = UnitCtrl.createUnit(unitCodeName,
                                   unitName,
                                   dbconn)
    end

    return unit

end

function UnitCtrl.retrieveOneUnit(unitCodeName::String,
                                  dbconn::LibPQ.Connection)

    unit::Union{Missing,Unit} =
        PostgresORM.retrieve_one_entity(Unit(codeName = unitCodeName),
                                        false, # complex props
                                        dbconn)
    return unit

end


function UnitCtrl.createUnit(unitCodeName::String,
                             unitName::String,
                             dbconn::LibPQ.Connection)

    unit = Unit(name = unitName,
                codeName = unitCodeName)
    unit = PostgresORM.create_entity!(unit,dbconn)
    return unit

end

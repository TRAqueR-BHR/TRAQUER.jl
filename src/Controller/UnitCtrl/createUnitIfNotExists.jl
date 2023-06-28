function UnitCtrl.createUnitIfNotExists(
    unitCodeName::AbstractString,
    unitName::AbstractString,
    dbconn::LibPQ.Connection
)

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

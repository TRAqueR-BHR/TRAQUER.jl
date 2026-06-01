function _TestUtils.createDummyUnits(
    dbconn::LibPQ.Connection;
    numberOfUnits::Integer = 10,
)::Vector{Unit}

    units = Unit[]

    for i in 1:numberOfUnits
        unit = UnitCtrl.createUnitIfNotExists(
            "TEST_UNIT_$(UUIDs.uuid4())",
            "Test unit $(i)",
            dbconn
        )
        push!(units, unit)
    end

    return units

end

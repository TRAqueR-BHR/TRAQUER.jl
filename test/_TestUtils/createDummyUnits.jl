function _TestUtils.createDummyUnits(
    dbconn::LibPQ.Connection;
    numberOfUnits::Integer = 10,
)::Vector{Unit}

    units = Unit[]

    for i in 1:numberOfUnits

        randomNumber = rand(1:9999)
        codeName = "TEST-UNIT-$randomNumber"

        unit = UnitCtrl.createUnitIfNotExists(
            codeName,
            codeName,
            dbconn
        )
        push!(units, unit)
    end

    return units

end

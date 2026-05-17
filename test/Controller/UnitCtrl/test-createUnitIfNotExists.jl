@testset "Test UnitCtrl.createUnitIfNotExists" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

        newUnit = UnitCtrl.createUnitIfNotExists(
            randstring(6), # unitCodeName::AbstractString,
            randstring(6), # unitName::AbstractString,
            dbconn)

        PostgresORM.delete_entity(newUnit,dbconn)

    end

end

@testset "Test UnitCtrl.createUnitIfNotExists" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn

        newUnit = UnitCtrl.createUnitIfNotExists(
            randstring(6), # unitCodeName::String,
            randstring(6), # unitName::String,
            dbconn)

        PostgresORM.delete_entity(newUnit,dbconn)

    end

end

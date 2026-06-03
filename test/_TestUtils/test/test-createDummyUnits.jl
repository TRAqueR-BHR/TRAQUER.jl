include("__prerequisite.jl")

@testset "Test _TestUtils.createDummyUnits" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        units = _TestUtils.createDummyUnits(dbconn)

        @test length(units) == 10
        @test all(unit -> unit isa Unit, units)
        @test all(unit -> !ismissing(unit.id), units)

        for unit in units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end

end

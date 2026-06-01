include("__prerequisite.jl")

@testset "Test _TestUtils.createDummyStays" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        patient = _TestUtils.createDummyPatient(dbconn)
        units = _TestUtils.createDummyUnits(dbconn)
        stays = _TestUtils.createDummyStays(patient, units, dbconn)

        @test length(stays) == 10
        @test all(stay -> stay isa Stay, stays)
        @test all(stay -> !ismissing(stay.id), stays)
        @test all(stay -> stay.patient.id == patient.id, stays)
        @test length(unique(getproperty.(stays, :hospitalizationInTime))) == 2

        for stay in stays
            PostgresORM.delete_entity(stay, dbconn)
        end
        PostgresORM.delete_entity(patient, dbconn)
        for unit in units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end

end

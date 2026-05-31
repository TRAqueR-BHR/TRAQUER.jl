include("__prerequisite.jl")

@testset "Test _TestUtils.createDummyPatient" begin
    @testset "Test _TestUtils.createDummyPatient WITHOUT specifying name, etc..." begin

        TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
            patient = _TestUtils.createDummyPatient(dbconn)

            @test patient isa Patient
            @test !ismissing(patient.id)

            PostgresORM.delete_entity(patient, dbconn)
        end

    end

    @testset "Test _TestUtils.createDummyPatient WITH specification of name, etc..." begin

        TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
            patient = _TestUtils.createDummyPatient(
                dbconn;
                firstname = "John",
                lastname = "Doe",
                birthdate = Date("1990-01-01"),
                ref = "12345"
            )

            @test patient isa Patient
            @test !ismissing(patient.id)

            PostgresORM.delete_entity(patient, dbconn)

        end

    end
end

include("__prerequisite.jl")

@testset "Test _TestUtils.createDummyCarrierInfectiousStatus" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
        patient = _TestUtils.createDummyPatient(dbconn)
        infectiousStatus = _TestUtils.createDummyCarrierInfectiousStatus(dbconn, patient)

        @test infectiousStatus isa InfectiousStatus
        @test !ismissing(infectiousStatus.id)
        @test infectiousStatus.patient.id == patient.id
        @test infectiousStatus.infectiousStatus == InfectiousStatusType.carrier

        PostgresORM.delete_entity(infectiousStatus, dbconn)

    end

end

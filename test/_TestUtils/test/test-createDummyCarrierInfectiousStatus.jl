include("__prerequisite.jl")

@testset "Test _TestUtils.createDummyCarrierInfectiousStatus" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        patient = _TestUtils.createDummyPatient(dbconn)
        infectiousStatus = _TestUtils.createDummyCarrierInfectiousStatus(patient, dbconn)

        @test infectiousStatus isa InfectiousStatus
        @test !ismissing(infectiousStatus.id)
        @test infectiousStatus.patient.id == patient.id
        @test infectiousStatus.infectiousStatus == InfectiousStatusType.carrier

        PostgresORM.delete_entity(infectiousStatus, dbconn)

    end

end

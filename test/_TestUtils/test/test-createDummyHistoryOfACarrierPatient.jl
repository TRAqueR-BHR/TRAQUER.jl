include("__prerequisite.jl")

@testset "Test _TestUtils.createDummyHistoryOfACarrierPatient" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        history = _TestUtils.createDummyHistoryOfACarrierPatient(dbconn)

        @test keys(history) == (:patient, :stays, :infectiousStatus, :units)
        @test history.patient isa Patient
        @test length(history.stays) == 10
        @test all(stay -> stay isa Stay, history.stays)
        @test history.infectiousStatus isa InfectiousStatus
        @test history.infectiousStatus.infectiousStatus == InfectiousStatusType.carrier
        @test history.stays[3].inTime < history.infectiousStatus.refTime < history.stays[3].outTime

        units = unique(getproperty.(history.stays, :unit))

        # Thanks to cascade delete on the foreign keys, deleting the patient also deletes
        # related stays and infectious statuses.
        PostgresORM.delete_entity(history.patient, dbconn)
        for unit in units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end

end

include("__prerequisite.jl")

@testset "Integration test ETLCtrl.ScopeCtrl.createStayMonitoringScopeListIfNotExist" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        # Create a realistic test history: one carrier patient, stays over several units,
        # and a carrier infectious status occurring during the third stay.
        history = _TestUtils.createDummyHistoryOfACarrierPatient(dbconn)

        # First call should build and persist the monitoring scopes needed for this carrier.
        stayMonitoringScopeList1 = ETLCtrl.ScopeCtrl.createStayMonitoringScopeListIfNotExist(
            history.infectiousStatus,
            dbconn
        )
        # Second call with the same infectious status should retrieve the existing scopes,
        # not create duplicates.
        stayMonitoringScopeList2 = ETLCtrl.ScopeCtrl.createStayMonitoringScopeListIfNotExist(
            history.infectiousStatus,
            dbconn
        )

        # The first call must return persisted monitoring scopes.
        @test !isnothing(stayMonitoringScopeList1)
        @test !isempty(stayMonitoringScopeList1)
        @test length(stayMonitoringScopeList1) == length(stayMonitoringScopeList2)
        @test all(scope -> !ismissing(scope.id), stayMonitoringScopeList1)
        # Idempotency check: the second call must return the same database rows.
        @test Set(getproperty.(stayMonitoringScopeList1, :id)) ==
              Set(getproperty.(stayMonitoringScopeList2, :id))

        # Thanks to cascade delete on the foreign keys, deleting the patient also deletes
        # related stays, infectious statuses, and monitoring scopes.
        PostgresORM.delete_entity(history.patient, dbconn)
        for unit in history.units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end

end

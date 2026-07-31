include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        
        history = _TestUtils.createDummyHistoryOfACarrierPatient(dbconn)
        ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes(dbconn)

        scopes = PostgresORM.retrieve_entity(
            StayMonitoringScope(justifyingInfectiousStatus = history.infectiousStatus),
            false,
            dbconn
        )

        @info "scopes " scopes
        @test length(scopes) > 0

        # Thanks to cascade delete on the foreign keys, deleting the patient also deletes
        # related stays and infectious statuses.
        PostgresORM.delete_entity(history.patient, dbconn)
        for unit in history.units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end
end

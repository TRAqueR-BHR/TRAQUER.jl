include("__prerequisite.jl")

@testset "Integration test ETLCtrl.ScopeCtrl.createStayExtractionScope" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        history = _TestUtils.createDummyHistoryOfACarrierPatient(dbconn)
        stayMonitoringScopeList = ETLCtrl.ScopeCtrl.createStayMonitoringScopeListIfNotExist(
            history.infectiousStatus,
            dbconn
        )

        stayExtractionScope = ETLCtrl.ScopeCtrl.createStayExtractionScope(
            first(stayMonitoringScopeList),
            dbconn
        )
        retrievedStayExtractionScope = PostgresORM.retrieve_one_entity(
            StayExtractionScope(id = stayExtractionScope.id),
            false,
            dbconn
        )

        @test stayExtractionScope isa StayExtractionScope
        @test !ismissing(stayExtractionScope.id)
        @test !ismissing(retrievedStayExtractionScope)
        @test retrievedStayExtractionScope.id == stayExtractionScope.id
        @test retrievedStayExtractionScope.stayMonitoringScope.id == first(stayMonitoringScopeList).id

        # Thanks to cascade delete on the foreign keys, deleting the patient also deletes
        # related stays, infectious statuses, monitoring scopes, and extraction scopes.
        PostgresORM.delete_entity(history.patient, dbconn)
        for unit in history.units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end

end

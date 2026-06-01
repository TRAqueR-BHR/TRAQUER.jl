include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.initializeStayMonitoringScope" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        patient = _TestUtils.createDummyPatient(dbconn)
        infectiousStatus = _TestUtils.createDummyCarrierInfectiousStatus(patient, dbconn)
        stayMonitoringScope = ETLCtrl.ScopeCtrl.initializeStayMonitoringScope(
            infectiousStatus, dbconn
        )

        # Clean up the created entities
        PostgresORM.delete_entity(infectiousStatus, dbconn)
        PostgresORM.delete_entity(patient, dbconn)
    end

end

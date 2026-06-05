include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.buildStayMonitoringScopeList" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        history = _TestUtils.createDummyHistoryOfACarrierPatient(dbconn)
        stayMonitoringScopeList = ETLCtrl.ScopeCtrl.buildStayMonitoringScopeList(
            history.infectiousStatus, dbconn
        )

        stayExtractionScope1::StayExtractionScope =
            ETLCtrl.ScopeCtrl.buildStayExtractionScope(
                stayMonitoringScopeList[1],
                dbconn
            )

        stayExtractionScope1 |> JSON.json |>
            n -> open(joinpath("tmp","json", "stay_extraction_scope1.json"), "w") do f
                write(f, n)
            end

        # Thanks to cascade delete on the foreign keys, deleting the patient also deletes
        # related stays and infectious statuses.
        PostgresORM.delete_entity(history.patient, dbconn)
        for unit in history.units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end

end

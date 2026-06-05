include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.buildStayMonitoringScopeList" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        history = _TestUtils.createDummyHistoryOfACarrierPatient(dbconn)
        stayMonitoringScopeList = ETLCtrl.ScopeCtrl.buildStayMonitoringScopeList(
            history.infectiousStatus, dbconn
        )

        # TRAQUERUtil.formatStructForPrinting(stayMonitoringScopeList) |> JSON.json |> n -> @info n

        # For better readability of the test output, we print the stay monitoring scope as JSON.
        stayMonitoringScopeList |>
            JSON.json |>
            # write to a file in the tmp folder of the project for easier inspection
            n -> open(joinpath("tmp","json", "stay_monitoring_scope.json"), "w") do f
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

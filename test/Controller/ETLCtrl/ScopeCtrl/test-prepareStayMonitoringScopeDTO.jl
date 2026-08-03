include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.prepareStayMonitoringScopeDTO" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        history = _TestUtils.createDummyHistoryOfACarrierPatient(dbconn)
        stayMonitoringScopeList = ETLCtrl.ScopeCtrl.buildStayMonitoringScopeList(
            history.infectiousStatus, dbconn
        )

        encryptionStr = _TestUtils.getDefaultEncryptionStr()

        for (i, stayMonitoringScope) in enumerate(stayMonitoringScopeList)
            stayMonitoringScopeDTO = ETLCtrl.ScopeCtrl.prepareStayMonitoringScopeDTO(
                stayMonitoringScope,
                encryptionStr,
                dbconn
            )

            # Serialize to a json file for easier inspection of the test output.
            stayMonitoringScopeDTO |> JSON.json |>
                n -> open(joinpath("tmp","json", "stay_monitoring_scope_dto_$i.json"), "w") do f
                    write(f, n)
                end

            @info "stay monitoring scope DTO: $(JSON.json(stayMonitoringScopeDTO))"
        end 
        # Thanks to cascade delete on the foreign keys, deleting the patient also deletes
        # related stays and infectious statuses.
        PostgresORM.delete_entity(history.patient, dbconn)
        for unit in history.units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end

end

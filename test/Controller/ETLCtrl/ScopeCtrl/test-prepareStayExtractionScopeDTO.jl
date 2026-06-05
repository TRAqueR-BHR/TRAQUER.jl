include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.prepareStayExtractionScopeDTO" begin

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

        stayExtractionScope2::StayExtractionScope =
            ETLCtrl.ScopeCtrl.buildStayExtractionScope(
                stayMonitoringScopeList[2],
                dbconn
            )

        encryptionStr = Main.getDefaultEncryptionStr()

        stayExtractionScopeDTO1 = ETLCtrl.ScopeCtrl.prepareStayExtractionScopeDTO(
            stayExtractionScope1,
            encryptionStr,
            dbconn
        )

        # Serialize to a json file for easier inspection of the test output.
        stayExtractionScopeDTO1 |> JSON.json |>
            n -> open(joinpath("tmp","json", "stay_extraction_scope_dto1.json"), "w") do f
                write(f, n)
            end

        stayExtractionScopeDTO2 = ETLCtrl.ScopeCtrl.prepareStayExtractionScopeDTO(
            stayExtractionScope2,
            encryptionStr,
            dbconn
        )

        # Serialize to a json file for easier inspection of the test output.
        stayExtractionScopeDTO2 |> JSON.json |>
            n -> open(joinpath("tmp","json", "stay_extraction_scope_dto2.json"), "w") do f
                write(f, n)
            end

        @info "stay extraction scope DTO: $(JSON.json(stayExtractionScopeDTO1))"

        # Thanks to cascade delete on the foreign keys, deleting the patient also deletes
        # related stays and infectious statuses.
        PostgresORM.delete_entity(history.patient, dbconn)
        for unit in history.units
            PostgresORM.delete_entity(unit, dbconn)
        end
    end

end

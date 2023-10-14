include("../runtests-prerequisite.jl")

@testset "Test AnalysisRequestCtrl.upsert!" begin


    TRAQUERUtil.createDBConnAndExecute() do dbconn
        analysisRequest = AnalysisRequest(
            requestType = AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae,
            unit = "SELECT * FROM unit LIMIT 1" |>
                n -> PostgresORM.execute_query_and_handle_result(n,Unit,missing,false,dbconn) |>
                first,
            creationTime = now(TRAQUERUtil.getTimeZone())
        )

        # Create
        AnalysisRequestCtrl.upsert!(analysisRequest, dbconn)
        @test !ismissing(analysisRequest.id)
        newId = analysisRequest.id

        # Update
        analysisRequest.id = missing
        analysisRequest.lastUpdateTime = now(TRAQUERUtil.getTimeZone())
        AnalysisRequestCtrl.upsert!(analysisRequest, dbconn)
        @test analysisRequest.id == newId

        # Cleanup after testing
        PostgresORM.delete_entity(analysisRequest, dbconn)

    end


end

include("../runtests-prerequisite.jl")

@testset "Test AnalysisRequestCtrl.updateAnalysisPendingAnalysesRequests" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn

        analysisRequest = PostgresORM.retrieve_one_entity(
            AnalysisRequest(id = "0acb1457-86a7-4397-b95b-d17be0a25d83"),
            false,
            dbconn
        )
        analysisResult = AnalysisResult(
            patient = analysisRequest.patient,
            requestType = analysisRequest.requestType,
            requestTime = analysisRequest.requestTime + Hour(1),
        )

        AnalysisRequestCtrl.updateAnalysisPendingAnalysesRequests(
            [analysisResult],
            dbconn
        )

    end

end

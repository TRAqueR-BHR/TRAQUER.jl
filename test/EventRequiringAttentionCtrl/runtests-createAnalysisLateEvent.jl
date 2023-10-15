include("../runtests-prerequisite.jl")

@testset "Test EventRequiringAttentionCtrl.createAnalysisLateEvent" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        analyisRequest = PostgresORM.retrieve_one_entity(
            AnalysisRequest(id = "0acb1457-86a7-4397-b95b-d17be0a25d83"),
            false,
            dbconn
        )
        EventRequiringAttentionCtrl.createAnalysisLateEvent(
            analyisRequest,
            dbconn
        )
    end

end

include("../runtests-prerequisite.jl")

@testset "Test EventRequiringAttentionCtrl.createSummaryOfEvents" begin

    events = TRAQUERUtil.createDBConnAndExecute() do dbconn
        EventRequiringAttentionCtrl.getNewImportantEvents(dbconn)
    end

    EventRequiringAttentionCtrl.createSummaryOfEvents(events) |> println

end

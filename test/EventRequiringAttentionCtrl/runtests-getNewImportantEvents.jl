include("../runtests-prerequisite.jl")

@testset "EventRequiringAttentionCtrl.getNewImportantEvents" begin

    events = TRAQUERUtil.createDBConnAndExecute() do dbconn
        EventRequiringAttentionCtrl.getNewImportantEvents(dbconn)
    end

    SplitApplyCombine.group(x -> x.eventType, events)
    SplitApplyCombine.groupreduce(x -> x.eventType, events)

end

include("../runtests-prerequisite.jl")

@testset "EventRequiringAttentionCtrl.getNewImportantEvents" begin

    events = TRAQUERUtil.createDBConnAndExecute() do dbconn
        EventRequiringAttentionCtrl.getNewImportantEvents(dbconn)
    end

end

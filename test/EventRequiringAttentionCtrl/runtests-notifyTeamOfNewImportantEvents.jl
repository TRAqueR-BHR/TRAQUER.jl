include("../runtests-prerequisite.jl")

@testset "Test EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        EventRequiringAttentionCtrl.notifyTeamOfNewImportantEvents(dbconn)
    end

end

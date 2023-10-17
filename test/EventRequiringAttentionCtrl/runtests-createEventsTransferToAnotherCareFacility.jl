include("../runtests-prerequisite.jl")

@testset "Test createEventsTransferToAnotherCareFacility" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        EventRequiringAttentionCtrl.createEventsTransferToAnotherCareFacility(dbconn)
    end

end

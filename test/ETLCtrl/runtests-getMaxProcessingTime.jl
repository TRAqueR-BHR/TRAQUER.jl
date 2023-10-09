include("../runtests-prerequisite.jl")

@testset "Test ETLCtrl.getMaxProcessingTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        ETLCtrl.getMaxProcessingTime(dbconn)
    end

end

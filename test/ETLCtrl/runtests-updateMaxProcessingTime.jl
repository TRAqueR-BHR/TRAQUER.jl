include("../runtests-prerequisite.jl")

@testset "Test ETLCtrl.updateMaxProcessingTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        ETLCtrl.updateMaxProcessingTime(dbconn)
    end

end

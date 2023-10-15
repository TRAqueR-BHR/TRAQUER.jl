include("../runtests-prerequisite.jl")

@testset "Test AnalysisRequestCtrl.getOverdueAnalysesRequests" begin


    TRAQUERUtil.createDBConnAndExecute() do dbconn
        AnalysisRequestCtrl.getOverdueAnalysesRequests(dbconn)
    end


end

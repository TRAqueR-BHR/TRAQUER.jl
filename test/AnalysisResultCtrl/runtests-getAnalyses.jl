include("../runtests-prerequisite.jl")

@testset "Test AnalysisResultCtrl.getAnalyses" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        AnalysisResultCtrl.getAnalyses(Patient(id = "fd69e782-1a15-444b-8143-ff98f01410d0"), dbconn)
    end

end

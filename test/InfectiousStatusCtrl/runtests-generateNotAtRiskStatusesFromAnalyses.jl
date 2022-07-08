include("../runtests-prerequisite.jl")

@testset "Test InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
        patient = Patient(id = "1b340313-7c2d-4fc6-ad38-b497c7a371a9")
        InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
            patient,
            (Date("2019-01-01"), Date("2023-01-01")),
            dbconn)
    end


end

include("../runtests-prerequisite.jl")

@testset "Test InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
        patient = Patient(id = "d538eb57-8c22-47bf-a9da-10b75da7b295")
        InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses(
            patient,
            (Date("2022-01-01"), Date("2023-01-01")),
            dbconn)
    end

end

@testset "Test InfectiousStatusCtrl.generateCarrierStatusesForEPC" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
        InfectiousStatusCtrl.generateCarrierStatusesForEPC(Date("2020-01-01"), dbconn)
    end

end

@testset "Test InfectiousStatusCtrl.getInfectiousStatusForListing" begin

    df = InfectiousStatusCtrl.getInfectiousStatusForListing(
                5,
                1,
                Vector{Dict{String,Any}}()
                ;cryptPwd = missing)[:rows]

    df = InfectiousStatusCtrl.getInfectiousStatusForListing(
                5,
                1,
                Vector{Dict{String,Any}}()
                ;cryptPwd = getDefaultEncryptionStr())[:rows]

end

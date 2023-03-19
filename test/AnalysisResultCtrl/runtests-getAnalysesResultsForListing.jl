include("../runtests-prerequisite.jl")

@testset "Test AnalysisResultCtrl.getAnalysesResultsForListing" begin

    df = AnalysisResultCtrl.getAnalysesResultsForListing(
        5,
        1,
        Vector{Dict{String,Any}}()
        ;cryptPwd = missing
    )[:rows]

    df = AnalysisResultCtrl.getAnalysesResultsForListing(
        5,
        1,
        Vector{Dict{String,Any}}()
        ;cryptPwd = getDefaultEncryptionStr()
    )[:rows]

end

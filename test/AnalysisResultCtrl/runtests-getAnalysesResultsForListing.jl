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

    # Filter on birthdate
    filtersAndSorting = Serialization.deserialize("test/AnalysisResultCtrl/assets/filtersAndSorting-on-patient-birthdate-for-function-getAnalysesResultsForListing.jld")
    df = AnalysisResultCtrl.getAnalysesResultsForListing(
        5,
        1,
        filtersAndSorting
        ;cryptPwd = getDefaultEncryptionStr()
    )[:rows]

end

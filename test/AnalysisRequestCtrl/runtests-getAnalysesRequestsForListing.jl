include("../runtests-prerequisite.jl")

@testset "Test AnalysisRequestCtrl.getAnalysesRequestsForListing" begin

    df = AnalysisRequestCtrl.getAnalysesRequestsForListing(
        5,
        1,
        Vector{Dict{String,Any}}()
        ;cryptPwd = missing
    )[:rows]

    df = AnalysisRequestCtrl.getAnalysesRequestsForListing(
        5,
        1,
        Vector{Dict{String,Any}}()
        ;cryptPwd = getDefaultEncryptionStr()
    )[:rows]

    # Filter on birthdate
    filtersAndSorting = Serialization.deserialize("test/AnalysisRequestCtrl/assets/filtersAndSorting-on-patient-birthdate-for-function-getAnalysesResultsForListing.jld")
    df = AnalysisResultCtrl.getAnalysesRequestsForListing(
        5,
        1,
        filtersAndSorting
        ;cryptPwd = getDefaultEncryptionStr()
    )[:rows]

end

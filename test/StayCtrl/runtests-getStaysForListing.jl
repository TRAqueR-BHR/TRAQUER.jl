include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.getStaysForListing" begin

    df = StayCtrl.getStaysForListing(
        5,
        1,
        Vector{Dict{String,Any}}()
        ;cryptPwd = missing
    )[:rows]

    df = StayCtrl.getStaysForListing(
        5,
        1,
        Vector{Dict{String,Any}}()
        ;cryptPwd = getDefaultEncryptionStr()
    )[:rows]

    # Filter on birthdate
    filtersAndSorting = Serialization.deserialize("test/AnalysisResultCtrl/assets/filtersAndSorting-on-patient-birthdate-for-function-getStaysForListing.jld")
    df = AnalysisResultCtrl.StayCtrl.getStaysForListing(
        5,
        1,
        filtersAndSorting
        ;cryptPwd = getDefaultEncryptionStr()
    )[:rows]

end

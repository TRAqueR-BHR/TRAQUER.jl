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

end

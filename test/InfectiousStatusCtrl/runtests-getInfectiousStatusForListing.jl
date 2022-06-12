include("../runtests-prerequisite.jl")

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

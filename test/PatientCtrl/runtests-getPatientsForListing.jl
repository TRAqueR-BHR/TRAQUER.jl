include("../runtests-prerequisite.jl")

@testset "Test PatientCtrl.getPatientsForListing" begin


    df = PatientCtrl.getPatientsForListing(
                5,
                1,
                Vector{Dict{String,Any}}()
                ;cryptPwd = getDefaultEncryptionStr())[:rows]

end

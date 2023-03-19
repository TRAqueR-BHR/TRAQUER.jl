include("../runtests-prerequisite.jl")

@testset "Test ContactExposureCtrl.getPatientExposuresForListing" begin

    df = TRAQUERUtil.createDBConnAndExecute() do dbconn
        ContactExposureCtrl.getPatientExposuresForListing(
            Patient(id = "a6e7a6c9-d77b-44a6-894d-94042d7e22e3"),
            getDefaultEncryptionStr(),
            dbconn
        )
    end

end

include("../runtests-prerequisite.jl")

@testset "Test ContactExposureCtrl.getPatientExposuresForListing" begin

    df = TRAQUERUtil.createDBConnAndExecute() do dbconn
        ContactExposureCtrl.getPatientExposuresForListing(
            Patient(id = "d538eb57-8c22-47bf-a9da-10b75da7b295"),
            getDefaultEncryptionStr(),
            dbconn
        )
    end

end

include("../runtests-prerequisite.jl")

@testset "Test PatientCtrl.getPatientDecrypt" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.getPatientDecrypt(
            Patient(id = "1b340313-7c2d-4fc6-ad38-b497c7a371a9"),
            Main.getDefaultEncryptionStr(),
            dbconn
        )
    end
end

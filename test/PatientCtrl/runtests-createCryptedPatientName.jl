include("../runtests-prerequisite.jl")

@testset "Test PatientCtrl.createCryptedPatientName" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.createCryptedPatientName("Renée",
                                            "Merueil",
                                            Main.getDefaultEncryptionStr(),
                                            dbconn)
    end
end

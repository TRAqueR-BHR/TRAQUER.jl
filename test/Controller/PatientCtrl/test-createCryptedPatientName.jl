include("__prerequisite.jl")
@testset "Test PatientCtrl.createCryptedPatientName" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.createCryptedPatientName("Renée",
                                            "Merueil",
                                            _TestUtils.getDefaultEncryptionStr(),
                                            dbconn)
    end
end

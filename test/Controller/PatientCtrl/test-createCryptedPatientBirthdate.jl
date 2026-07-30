include("__prerequisite.jl")
@testset "Test PatientCtrl.createCryptedPatientBirthdate" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.createCryptedPatientBirthdate(Date("1982-04-10"),
                                                _TestUtils.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

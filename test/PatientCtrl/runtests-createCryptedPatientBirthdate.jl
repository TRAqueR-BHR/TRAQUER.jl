include("../runtests-prerequisite.jl")

@testset "Test PatientCtrl.createCryptedPatientBirthdate" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.createCryptedPatientBirthdate(Date("1982-04-10"),
                                                Main.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

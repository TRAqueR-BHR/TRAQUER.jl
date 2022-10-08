include("../runtests-prerequisite.jl")

@testset "Test PatientCtrl.retrievePatientsFromBirthdate" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromBirthdate(Date("1982-04-10"),
                                                Main.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

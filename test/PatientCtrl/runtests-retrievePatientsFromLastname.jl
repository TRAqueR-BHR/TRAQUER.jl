include("../runtests-prerequisite.jl")

@testset "Test PatientCtrl.retrievePatientsFromLastname" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromLastname("Merueil",
                                                Main.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

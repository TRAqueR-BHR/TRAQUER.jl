include("__prerequisite.jl")
@testset "Test PatientCtrl.retrieveOnePatient" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrieveOnePatient("Renée",
                                    "Merueil",
                                    Date("1982-04-10"),
                                    Main.getDefaultEncryptionStr(),
                                    dbconn)
    end
end

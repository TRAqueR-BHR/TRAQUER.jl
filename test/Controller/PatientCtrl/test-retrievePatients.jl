include("__prerequisite.jl")
@testset "Test PatientCtrl.retrievePatients" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatients("Renée",
                                    "Merueil",
                                    Date("1982-04-10"),
                                    Main.getDefaultEncryptionStr(),
                                    dbconn)
    end
end

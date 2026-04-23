include("__prerequisite.jl")
@testset "Test PatientCtrl.createPatient" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.createPatient("Renée",
                                "Merueil",
                                Date("1982-04-10"),
                                TRAQUER.Enum.Gender.male,
                                Main.getDefaultEncryptionStr(),
                                dbconn)
    end
end

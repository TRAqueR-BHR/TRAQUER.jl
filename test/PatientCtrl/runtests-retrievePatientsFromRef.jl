include("../runtests-prerequisite.jl")

@testset "Test PatientCtrl.retrievePatientsFromRef" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromRef("8496130",
                                                Main.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

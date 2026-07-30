include("__prerequisite.jl")
@testset "Test PatientCtrl.retrievePatientsFromLastname" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromLastname("Merueil",
                                                _TestUtils.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

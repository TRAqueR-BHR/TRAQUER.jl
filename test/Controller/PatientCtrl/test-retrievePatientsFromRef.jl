include("__prerequisite.jl")
@testset "Test PatientCtrl.retrievePatientsFromRef" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromRef("8496130",
                                                _TestUtils.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

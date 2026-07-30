include("__prerequisite.jl")
@testset "Test PatientCtrl.retrievePatientsFromBirthdate" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromBirthdate(Date("1982-04-10"),
                                                _TestUtils.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

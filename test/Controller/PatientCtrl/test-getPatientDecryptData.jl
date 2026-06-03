include("__prerequisite.jl")
@testset "Test PatientCtrl.getPatientDecrypt" begin
    @testset "Test PatientCtrl.getPatientDecrypt WITHOUT the patient ref" begin
        patientDecript = TRAQUERUtil.createDBConnAndExecute() do dbconn
            PatientCtrl.getPatientDecrypt(
                Patient(id = "9c3fc376-2ce1-407b-9276-4f5638a6c78a"),
                Main.getDefaultEncryptionStr(),
                dbconn
            )
        end
        @test ismissing(patientDecript.patientRef)
    end

    @testset "Test PatientCtrl.getPatientDecrypt WITH the patient ref" begin
        patientDecript = TRAQUERUtil.createDBConnAndExecute() do dbconn
            PatientCtrl.getPatientDecrypt(
                Patient(id = "9c3fc376-2ce1-407b-9276-4f5638a6c78a"),
                Main.getDefaultEncryptionStr(),
                dbconn,
                includePatientRef = true
            )
        end
        @test !ismissing(patientDecript.patientRef)
    end
end

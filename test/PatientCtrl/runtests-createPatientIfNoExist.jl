include("../runtests-prerequisite.jl")

@testset "Test PatientCtrl.createPatientIfNoExist" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn

        PatientCtrl.createPatientIfNoExist(randstring(6), # firstname
                                            randstring(6), # lastname
                                            Date("1978-09-12"),
                                            rand(Int32) |> abs |> string, # hospital ref
                                            getDefaultEncryptionStr(),
                                            dbconn)
    end
end


@testset "Test PatientCtrl.createPatientIfNoExist" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        patient = PatientCtrl.createPatientIfNoExist("Renée",
                                        "Merueil",
                                            Date("1984-04-10"),
                                            TRAQUER.Enum.Gender.male,
                                            Main.getDefaultEncryptionStr(),
                                            dbconn)
    end
end

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

@testset "Test PatientCtrl.createCryptedPatientName" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.createCryptedPatientName("Renée",
                                            "Merueil",
                                            Main.getDefaultEncryptionStr(),
                                            dbconn)
    end
end

@testset "Test PatientCtrl.createCryptedPatientBirthdate" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.createCryptedPatientBirthdate(Date("1982-04-10"),
                                                Main.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

@testset "Test PatientCtrl.retrievePatientsFromLastname" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromLastname("Merueil",
                                                Main.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

@testset "Test PatientCtrl.retrievePatientsFromBirthdate" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromBirthdate(Date("1982-04-10"),
                                                Main.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

@testset "Test PatientCtrl.retrievePatientsFromRef" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatientsFromRef("8496130",
                                                Main.getDefaultEncryptionStr(),
                                                dbconn)
    end
end

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

@testset "Test PatientCtrl.retrievePatients" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrievePatients("Renée",
                                    "Merueil",
                                    Date("1982-04-10"),
                                    Main.getDefaultEncryptionStr(),
                                    dbconn)
    end
end

@testset "Test PatientCtrl.retrieveOnePatient" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        PatientCtrl.retrieveOnePatient("Renée",
                                    "Merueil",
                                    Date("1982-04-10"),
                                    Main.getDefaultEncryptionStr(),
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

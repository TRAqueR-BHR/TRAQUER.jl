@testset "Test PatientCtrl.createPatientIfNoExist" begin
    PatientCtrl.createPatientIfNoExist("François",
                                        "Morel",
                                        Date("1978-09-12"))
end

@testset "Test PatientCtrl.createCryptedPatientName" begin
    dbconn = TRAQUERUtil.openDBConn()
    PatientCtrl.createCryptedPatientName("Renée",
                                         "Merueil",
                                         Main.getDefaultEncryptionStr(),
                                         dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test PatientCtrl.createCryptedPatientBirthdate" begin
    dbconn = TRAQUERUtil.openDBConn()
    PatientCtrl.createCryptedPatientBirthdate(Date("1982-04-10"),
                                              Main.getDefaultEncryptionStr(),
                                              dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test PatientCtrl.retrievePatientsFromLastname" begin
    dbconn = TRAQUERUtil.openDBConn()
    PatientCtrl.retrievePatientsFromLastname("Merueil",
                                              Main.getDefaultEncryptionStr(),
                                              dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test PatientCtrl.retrievePatientsFromBirthdate" begin
    dbconn = TRAQUERUtil.openDBConn()
    PatientCtrl.retrievePatientsFromBirthdate(Date("1982-04-10"),
                                              Main.getDefaultEncryptionStr(),
                                              dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test PatientCtrl.retrievePatientsFromRef" begin
    dbconn = TRAQUERUtil.openDBConn()
    PatientCtrl.retrievePatientsFromRef("8496130",
                                              Main.getDefaultEncryptionStr(),
                                              dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test PatientCtrl.createPatient" begin
    dbconn = TRAQUERUtil.openDBConn()
    PatientCtrl.createPatient("Renée",
                              "Merueil",
                              Date("1982-04-10"),
                              TRAQUER.Enum.Gender.male,
                              Main.getDefaultEncryptionStr(),
                              dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test PatientCtrl.retrievePatients" begin
    dbconn = TRAQUERUtil.openDBConn()
    PatientCtrl.retrievePatients("Renée",
                                 "Merueil",
                                  Date("1982-04-10"),
                                  Main.getDefaultEncryptionStr(),
                                  dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test PatientCtrl.retrieveOnePatient" begin
    dbconn = TRAQUERUtil.openDBConn()
    PatientCtrl.retrieveOnePatient("Renée",
                                 "Merueil",
                                  Date("1982-04-10"),
                                  Main.getDefaultEncryptionStr(),
                                  dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

@testset "Test PatientCtrl.createPatientIfNoExist" begin
    dbconn = TRAQUERUtil.openDBConn()
    patient = PatientCtrl.createPatientIfNoExist("Renée",
                                       "Merueil",
                                        Date("1984-04-10"),
                                        TRAQUER.Enum.Gender.male,
                                        Main.getDefaultEncryptionStr(),
                                        dbconn)
    TRAQUERUtil.closeDBConn(dbconn)
end

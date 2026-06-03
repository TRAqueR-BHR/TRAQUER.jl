function _TestUtils.createDummyPatient(
    dbconn::LibPQ.Connection;
    firstname::AbstractString = "TestFirstname_$(randstring(8))",
    lastname::AbstractString = "TestLastname_$(randstring(8))",
    birthdate::Date = Date("1970-01-01"),
    ref::AbstractString = "IPP-$(rand(10000:99999))",
    encryptionStr::AbstractString = Main.getDefaultEncryptionStr(),
)::Patient

    return PatientCtrl.createPatientIfNoExist(
        firstname,
        lastname,
        birthdate,
        ref,
        encryptionStr,
        dbconn
    )

end

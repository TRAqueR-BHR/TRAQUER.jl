"""
    PatientCtrl.updatePatientNameAndBirthdate(
        patient::Patient,
        firstname::String,
        lastname::String,
        birthdate::Date,
        encryptionStr::String,
        dbconn::LibPQ.Connection)

Updates the firstname, lastname and birth date of the patient

"""
function PatientCtrl.updatePatientNameAndBirthdate(
    patient::Patient,
    firstname::String,
    lastname::String,
    birthdate::Date,
    encryptionStr::String,
    dbconn::LibPQ.Connection)

    # Retrieve the entity from the database (to make sure we have all the properties set)
    patient = PostgresORM.retrieve_one_entity(Patient(id = patient.id),false,dbconn)

    # Create the new crypted instances for the name and the birthdate
    cryptedPatientName = PatientCtrl.createCryptedPatientName(firstname,
                                                              lastname,
                                                              encryptionStr,
                                                              dbconn)

    cryptedPatientBirthdate = PatientCtrl.createCryptedPatientBirthdate(birthdate,
                                                                        encryptionStr,
                                                                        dbconn)

    # Update the patient with these new crypted references
    patient.patientNameCrypt = cryptedPatientName
    patient.patientBirthdateCrypt = cryptedPatientBirthdate
    PostgresORM.update_entity!(patient,dbconn)

    # Remove the orphaned crypted values
    PatientCtrl.deleteOrphanedPatientCrypt(dbconn)

    return patient

end

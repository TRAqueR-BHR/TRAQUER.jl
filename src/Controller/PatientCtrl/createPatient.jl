function PatientCtrl.createPatient(firstname::String,
                                   lastname::String,
                                   birthdate::Date,
                                   ref::Union{String,Missing},
                                   encryptionStr::String,
                                   dbconn::LibPQ.Connection)

    # If no patient ref is given create one
    if ismissing(ref)
        ref = UUIDs.uuid4() |> string
    end

    cryptedPatientName = PatientCtrl.createCryptedPatientName(firstname,
                                                              lastname,
                                                              encryptionStr,
                                                              dbconn)

    cryptedPatientBirthdate = PatientCtrl.createCryptedPatientBirthdate(birthdate,
                                                                        encryptionStr,
                                                                        dbconn)

    cryptedPatientRef = PatientCtrl.createCryptedPatientRef(ref,
                                                            encryptionStr,
                                                            dbconn)

    # Generate a patient reference used that can be shared between users with the
    #   dataset password and the administrators
    # patientRef = TRAQUERUtil.generateHumanReadableUniqueRef(patient)

    patient = Patient(patientNameCrypt = cryptedPatientName,
                      patientBirthdateCrypt = cryptedPatientBirthdate,
                      patientRefCrypt = cryptedPatientRef)

    PostgresORM.create_entity!(patient,dbconn)
    return patient
end

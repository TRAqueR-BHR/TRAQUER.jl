function PatientCtrl.createCryptedPatientBirthdate(birthdate::Date,
                                                   encryptionStr::String,
                                                   dbconn::LibPQ.Connection)

    # Create partition if needed
    TRAQUERUtil.createPartitionPatientBirthdateIfNotExist(birthdate,
                                                          dbconn)

    birthdateAsStr = string(birthdate)
    year = Dates.year(birthdate)

    insertQueryStr =
        "INSERT INTO public.patient_birthdate_crypt(year,
                                               birthdate_crypt)
         VALUES (\$2, -- year
                 pgp_sym_encrypt(\$3,\$1) -- birthdate_crypt
                 )
         RETURNING *"
    insertQueryArgs = [encryptionStr,
                       year,
                       birthdateAsStr]
    patientNameCrypt =
        PostgresORM.execute_query_and_handle_result(insertQueryStr,
                                                    PatientBirthdateCrypt,
                                                    insertQueryArgs,
                                                    false,
                                                    dbconn)
    return first(patientNameCrypt)
end

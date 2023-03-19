function PatientCtrl.retrievePatientsFromBirthdate(birthdate::Date,
                                                   encryptionStr::String,
                                                   dbconn::LibPQ.Connection)

    birthdateAsStr = string(birthdate)
    _year = year(birthdate)
    queryString = "SELECT p.* FROM patient p
                   INNER JOIN public.patient_birthdate_crypt pbc
                        ON (p.birth_year = pbc.year
                        AND p.birthdate_crypt_id = pbc.id)
                   WHERE pbc.year = \$3
                     AND pgp_sym_decrypt(pbc.birthdate_crypt, \$1) = \$2
                   "
    queryArgs = [encryptionStr,
                 birthdateAsStr,
                 _year]
    patients = PostgresORM.execute_query_and_handle_result(
            queryString, Patient, queryArgs,
            false, # complex props
            dbconn)

    patients

end

function PatientCtrl.getPatientDecrypt(
    patient::Patient,
    encryptionStr::String,
    dbconn::LibPQ.Connection
)

    patientDecryptData = "
        SELECT p.id AS patient_id
               ,pgp_sym_decrypt(pbc.birthdate_crypt, \$1) AS birthdate
               ,pgp_sym_decrypt(pnc.firstname_crypt, \$1) AS firstname
               ,pgp_sym_decrypt(pnc.lastname_crypt, \$1) AS lastname
        FROM patient p
        JOIN patient_birthdate_crypt pbc
          ON  pbc.year = p.birth_year
          AND pbc.id = p.birthdate_crypt_id
        JOIN patient_name_crypt pnc
          ON  pnc.lastname_first_letter = p.lastname_first_letter
          AND pnc.id = p.name_crypt_id
        WHERE p.id = \$2" |>
            # n -> PostgresORM.execute_plain_query(
            #     n,
            #     [encryptionStr, patient.id],
            #     dbconn
            # )
            n -> PostgresORM.execute_query_and_handle_result(
                n,
                PatientDecrypt,
                [encryptionStr, patient.id],
                false,
                dbconn
            ) |>
            n -> if isempty(n) missing else first(n) end

    return patientDecryptData

end

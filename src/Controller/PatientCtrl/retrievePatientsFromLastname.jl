function PatientCtrl.retrievePatientsFromLastname(lastname::AbstractString,
                                                  encryptionStr::AbstractString,
                                                  dbconn::LibPQ.Connection)

    lastname = string(lastname)
    lastname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(lastname)
    lastnameFirstLetter = lastname_forCp[1]
    queryString = "SELECT p.* FROM patient p
                   INNER JOIN public.patient_name_crypt pnc
                      ON (p.lastname_first_letter = pnc.lastname_first_letter
                        AND p.name_crypt_id = pnc.id)
                   WHERE pnc.lastname_first_letter = \$3
                     AND pgp_sym_decrypt(pnc.lastname_for_cp_crypt, \$1) = \$2"

    queryArgs = [encryptionStr,
                 lastname_forCp,
                 lastnameFirstLetter]
    patients = PostgresORM.execute_query_and_handle_result(
            queryString, Patient, queryArgs,
            false, # complex props
            dbconn)

    patients

end

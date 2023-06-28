function PatientCtrl.retrievePatients(firstname::AbstractString,
                                     lastname::AbstractString,
                                     birthdate::Date,
                                     encryptionStr::AbstractString,
                                     dbconn::LibPQ.Connection)

     lastname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(lastname)
     firstname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(firstname)
     lastnameFirstLetter = lastname_forCp[1]
     _year = Dates.year(birthdate)
     queryString = "SELECT p.* FROM patient p
                    INNER JOIN public.patient_name_crypt pnc
                      ON (p.lastname_first_letter = pnc.lastname_first_letter
                        AND p.name_crypt_id = pnc.id)
                    INNER JOIN public.patient_birthdate_crypt pbc
                        ON (p.birth_year = pbc.year
                        AND p.birthdate_crypt_id = pbc.id)
                    WHERE p.lastname_first_letter = \$2
                      AND p.birth_year = \$3
                      AND pgp_sym_decrypt(pnc.lastname_for_cp_crypt, \$1) = \$4
                      AND pgp_sym_decrypt(pnc.firstname_for_cp_crypt, \$1) = \$5"

     queryArgs = [encryptionStr,
                  lastnameFirstLetter,
                  _year,
                  lastname_forCp,
                  firstname_forCp]
     patients = PostgresORM.execute_query_and_handle_result(
             queryString, Patient, queryArgs,
             false, # complex props
             dbconn)

     patients
end

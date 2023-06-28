
function PatientCtrl.createCryptedPatientName(firstname::AbstractString,
                                              lastname::AbstractString,
                                              encryptionStr::AbstractString,
                                              dbconn::LibPQ.Connection)

      # Create partition if needed
      TRAQUERUtil.createPartitionPatientNameIfNotExist(lastname,
                                                       dbconn)

      # The value used for comparion
      # Eg, "François Abélard" -> "abelard francois"
      firstname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(firstname)
      lastname_forCp = TRAQUERUtil.cleanStringForEncryptedValueCp(lastname)
      lastnameFirstLetter = lastname_forCp[1]

      insertQueryStr =
          "INSERT INTO public.patient_name_crypt(lastname_first_letter,
                                                 lastname_crypt,
                                                 lastname_for_cp_crypt,
                                                 firstname_crypt,
                                                 firstname_for_cp_crypt)
           VALUES (\$2, -- lastname_first_letter
                   pgp_sym_encrypt(\$3,\$1), -- lastname_crypt
                   pgp_sym_encrypt(\$4,\$1), -- lastname_for_cp_crypt
                   pgp_sym_encrypt(\$5,\$1), -- firstname_crypt
                   pgp_sym_encrypt(\$6,\$1)  -- firstname_for_cp_crypt
                   )
           RETURNING *"
      insertQueryArgs = [encryptionStr,
                         lastnameFirstLetter,
                         lastname,
                         lastname_forCp,
                         firstname,
                         firstname_forCp,
                         ]

      patientNameCrypt =
          PostgresORM.execute_query_and_handle_result(insertQueryStr,
                                                      PatientNameCrypt,
                                                      insertQueryArgs,
                                                      false,
                                                      dbconn)
      return first(patientNameCrypt)

end

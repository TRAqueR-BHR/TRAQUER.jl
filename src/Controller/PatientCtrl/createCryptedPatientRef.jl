function PatientCtrl.createCryptedPatientRef(ref::String,
                                             encryptionStr::String,
                                             dbconn::LibPQ.Connection)

       # Create partition if needed
       TRAQUERUtil.createPartitionPatientRefIfNotExist(ref,
                                                       dbconn)

      refOneChar = PatientCtrl.getRefOneChar(ref)

      insertQueryStr =
          "INSERT INTO public.patient_ref_crypt(one_char,
                                                ref_crypt)
           VALUES (\$2, -- one_char
                   pgp_sym_encrypt(\$3,\$1) -- ref_crypt
                   )
           RETURNING *"
      insertQueryArgs = [encryptionStr,
                         refOneChar,
                         ref]
      patientRefCrypt =
          PostgresORM.execute_query_and_handle_result(insertQueryStr,
                                                      PatientRefCrypt,
                                                      insertQueryArgs,
                                                      false,
                                                      dbconn)
      return first(patientRefCrypt)

end

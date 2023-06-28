function PatientCtrl.retrievePatientsFromRef(ref::AbstractString,
                                             encryptionStr::AbstractString,
                                             dbconn::LibPQ.Connection)

    refOneChar = PatientCtrl.getRefOneChar(ref)
    queryString = "SELECT p.* FROM patient p
                   INNER JOIN public.patient_ref_crypt prc
                      ON (p.ref_one_char = prc.one_char
                        AND p.ref_crypt_id = prc.id)
                   WHERE prc.one_char = \$3
                     AND pgp_sym_decrypt(prc.ref_crypt, \$1) = \$2"

    queryArgs = [encryptionStr,
                 ref,
                 refOneChar]

    patients = PostgresORM.execute_query_and_handle_result(
            queryString, Patient, queryArgs,
            false, # complex props
            dbconn)

    patients

end

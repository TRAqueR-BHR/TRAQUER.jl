function AnalysisResultCtrl.retrieveAnalysesResultsFromRef(
    patient::Patient,
    ref::String,
    encryptionStr::String,
    dbconn::LibPQ.Connection
)

    refOneChar = AnalysisResultCtrl.getRefOneChar(ref)
    queryString = "SELECT a.* FROM analysis_result a
                   INNER JOIN patient p
                      ON a.patient_id = p.id
                   INNER JOIN public.analysis_ref_crypt arc
                      ON (a.ref_one_char = arc.one_char
                        AND a.ref_crypt_id = arc.id)
                   WHERE p.id = \$4
                     AND  arc.one_char = \$3
                     AND pgp_sym_decrypt(arc.ref_crypt, \$1) = \$2"

    queryArgs = [encryptionStr,
                 ref,
                 refOneChar,
                 patient.id]
    analyses = PostgresORM.execute_query_and_handle_result(
            queryString, AnalysisResult, queryArgs,
            false, # complex props
            dbconn)

    analyses

end

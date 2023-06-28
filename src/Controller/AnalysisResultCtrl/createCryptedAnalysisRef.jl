function AnalysisResultCtrl.createCryptedAnalysisRef(
    ref::AbstractString, encryptionStr::AbstractString, dbconn::LibPQ.Connection
)

       # Create partition if needed
       TRAQUERUtil.createPartitionAnalysisRefIfNotExist(ref,
                                                        dbconn)

      refOneChar = AnalysisResultCtrl.getRefOneChar(ref)

      insertQueryStr =
          "INSERT INTO public.analysis_ref_crypt(one_char,
                                                 ref_crypt)
           VALUES (\$2, -- one_char
                   pgp_sym_encrypt(\$3,\$1) -- ref_crypt
                   )
           RETURNING *"
      insertQueryArgs = [encryptionStr,
                         refOneChar,
                         ref]
      analysisRefCrypt =
          PostgresORM.execute_query_and_handle_result(insertQueryStr,
                                                      AnalysisRefCrypt,
                                                      insertQueryArgs,
                                                      false,
                                                      dbconn)
      return first(analysisRefCrypt)

end

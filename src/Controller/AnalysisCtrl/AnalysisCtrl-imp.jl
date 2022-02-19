function AnalysisCtrl.createAnalysisIfNotExist(patient::Patient,
                                               stay::Stay,
                                               analysisType::AnalysisType,
                                               requestDateTime::ZonedDateTime,
                                               ref::String,
                                               encryptionStr::String,
                                               sampleType::String,
                                               result::Union{Missing,String},
                                               dbconn::LibPQ.Connection)

    # Look for an analysis
    analysis::Union{Missing,Analysis} =
        AnalysisCtrl.retrieveOneAnalysis(patient,
                                         ref,
                                         encryptionStr,
                                         dbconn)

    # Create analysis if missing
    if ismissing(analysis)
        analysis = AnalysisCtrl.createAnalysis(patient,
                                               stay,
                                               requestDateTime,
                                               analysisType,
                                               sampleType,
                                               result,
                                               ref,
                                               encryptionStr,
                                               dbconn::LibPQ.Connection)
    else
        # Update the result if needed
        if (result !== analysis.resultValue || sampleType !== analysis.sampleType)
            analysis.sampleType = sampleType
            analysis.resultValue = result
            PostgresORM.update_entity!(analysis,dbconn)
        end
    end

    return analysis

end

function AnalysisCtrl.getRefOneChar(ref::String)
    refOneChar = lowercase(last(ref))
    return refOneChar
end

function AnalysisCtrl.retrieveOneAnalysis(patient::Patient,
                                          ref::String,
                                          encryptionStr::String,
                                          dbconn::LibPQ.Connection)

    analyses = AnalysisCtrl.retrieveAnalysesFromRef(patient,
                                                   ref,
                                                   encryptionStr,
                                                   dbconn)
    if isempty(analyses)
       return missing
    else
       return first(analyses)
    end

end


function AnalysisCtrl.retrieveAnalysesFromRef(patient::Patient,
                                              ref::String,
                                              encryptionStr::String,
                                              dbconn::LibPQ.Connection)

    refOneChar = AnalysisCtrl.getRefOneChar(ref)
    queryString = "SELECT a.* FROM analysis a
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
            queryString, Analysis, queryArgs,
            false, # complex props
            dbconn)

    analyses

end

function AnalysisCtrl.createAnalysis(patient::Patient,
                                     stay::Stay,
                                     requestDateTime::ZonedDateTime,
                                     analysisType::Union{Missing,AnalysisType},
                                     sampleType::String,
                                     result::Union{Missing,String},
                                     ref::String,
                                     encryptionStr::String,
                                     dbconn::LibPQ.Connection)


     analysisRefCrypt = AnalysisCtrl.createCryptedAnalysisRef(ref,
                                                              encryptionStr,
                                                              dbconn)

     analysis = Analysis(patient = patient,
                         stay = stay,
                         analysisRefCrypt = analysisRefCrypt,
                         requestDateTime = requestDateTime,
                         analysisType = analysisType,
                         sampleType = sampleType,
                         resultValue = result)
     TRAQUERUtil.createPartitionAnalysisIfNotExist(analysis, dbconn)
     PostgresORM.create_entity!(analysis,dbconn)

     return analysis

end

function AnalysisCtrl.createCryptedAnalysisRef(ref::String,
                                               encryptionStr::String,
                                               dbconn::LibPQ.Connection)

       # Create partition if needed
       TRAQUERUtil.createPartitionAnalysisRefIfNotExist(ref,
                                                        dbconn)

      refOneChar = AnalysisCtrl.getRefOneChar(ref)

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

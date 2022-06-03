function AnalysisResultCtrl.createAnalysisResultIfNotExist(
    patient::Patient,
    stay::Stay,
    requestType::ANALYSIS_REQUEST_TYPE,
    requestTime::ZonedDateTime,
    ref::String,
    encryptionStr::String,
    sampleMaterial::Union{Missing,SAMPLE_MATERIAL_TYPE},
    result::Union{Missing,ANALYSIS_RESULT_VALUE_TYPE},
    resultTime::Union{Missing,ZonedDateTime},
    dbconn::LibPQ.Connection
)

    # Look for an analysis
    analysisResult::Union{Missing,AnalysisResult} =
        AnalysisResultCtrl.retrieveOneAnalysisResult(
            patient,
            ref,
            encryptionStr,
            dbconn
        )

    # Create analysis if missing
    if ismissing(analysisResult)

        analysisResult = AnalysisResultCtrl.createAnalysisResult(
            patient,
            stay,
            requestTime,
            requestType,
            sampleMaterial,
            result,
            resultTime,
            ref,
            encryptionStr,
            dbconn)

    else
        # Update the result if needed
        if (result !== analysisResult.result
            || sampleMaterial !== analysisResult.sampleMaterialType)
            analysisResult.sampleMaterialType = sampleMaterial
            analysisResult.requestType = requestType
            analysisResult.result = result
            PostgresORM.update_entity!(analysisResult,dbconn)
        end
    end

    return analysisResult

end

function AnalysisResultCtrl.getRefOneChar(ref::String)
    refOneChar = lowercase(last(ref))
    return refOneChar
end

function AnalysisResultCtrl.retrieveOneAnalysisResult(
    patient::Patient,
    ref::String,
    encryptionStr::String,
    dbconn::LibPQ.Connection
)

    analyses = AnalysisResultCtrl.retrieveAnalysesResultsFromRef(
        patient, ref, encryptionStr, dbconn
    )

    if isempty(analyses)
       return missing
    else
       return first(analyses)
    end

end


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

function AnalysisResultCtrl.createAnalysisResult(
    patient::Patient,
    stay::Stay,
    requestTime::ZonedDateTime,
    requestType::ANALYSIS_REQUEST_TYPE,
    sampleMaterialType::Union{Missing,SAMPLE_MATERIAL_TYPE},
    result::Union{Missing,ANALYSIS_RESULT_VALUE_TYPE},
    resultTime::Union{Missing,ZonedDateTime},
    ref::String,
    encryptionStr::String,
    dbconn::LibPQ.Connection
)


    analysisRefCrypt = AnalysisResultCtrl.createCryptedAnalysisRef(
        ref, encryptionStr, dbconn
    )

    analysisResult = AnalysisResult(
        patient = patient,
        stay = stay,
        analysisRefCrypt = analysisRefCrypt,
        requestTime = requestTime,
        requestType = requestType,
        sampleMaterialType = sampleMaterialType,
        result = result,
        resultTime = resultTime
        )

     TRAQUERUtil.createPartitionAnalysisResultIfNotExist(analysisResult, dbconn)
     PostgresORM.create_entity!(analysisResult,dbconn)

     return analysisResult

end

function AnalysisResultCtrl.createCryptedAnalysisRef(
    ref::String, encryptionStr::String, dbconn::LibPQ.Connection
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

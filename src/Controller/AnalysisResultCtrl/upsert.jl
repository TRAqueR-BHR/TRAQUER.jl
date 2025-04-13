
function AnalysisResultCtrl.upsert!(
    analysisResult::AnalysisResult,
    analysisRef::AbstractString,
    encryptionStr::AbstractString,
    dbconn::LibPQ.Connection
)

    # Look for an analysis from the ref
    existingAnalysisResult::Union{Missing,AnalysisResult} =
        AnalysisResultCtrl.retrieveOneAnalysisResult(
            analysisResult.patient,
            analysisRef,
            encryptionStr,
            dbconn
        )

    # Create analysis if missing
    if ismissing(existingAnalysisResult)

        # WARNING:
        # The following call creates a new record in table analysis_ref_crypt based on the
        # 'analysisRef' passed as argument. The object analysisResult probably has its
        # property 'analysisRefCrypt' missing which in the case of an update could lead to
        # an overwriting of a non null 'ref_crypt_id' in the database.
        # That is why in the case of an update we copy the 'analysisRefCrypt' property from
        # the existing instance
        analysisResult = AnalysisResultCtrl.createAnalysisResult(
            analysisResult.patient,
            analysisResult.stay,
            analysisResult.requestTime,
            analysisResult.requestType,
            analysisResult.sampleMaterialType,
            analysisResult.result,
            analysisResult.resultRawText,
            analysisResult.resultTime,
            analysisRef,
            encryptionStr,
            dbconn
        )

    else

        analysisResult.id = existingAnalysisResult.id

        # Set the property 'analysisRefCrypt' with the one from the existing record to avoid
        # overwriting the existing record with missing
        analysisResult.analysisRefCrypt = existingAnalysisResult.analysisRefCrypt

        # We only want to reprocess if the result is different from existing
        if existingAnalysisResult.result !== analysisResult.result
            # Reset the processing time so that the analyis gets processed again with the
            # additional information
            analysisResult.sysProcessingTime = missing
        end

        PostgresORM.update_entity!(analysisResult,dbconn)

    end

    return analysisResult

end

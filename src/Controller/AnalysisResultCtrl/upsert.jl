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
        PostgresORM.update_entity!(analysisResult,dbconn)

    end

    return analysisResult

end

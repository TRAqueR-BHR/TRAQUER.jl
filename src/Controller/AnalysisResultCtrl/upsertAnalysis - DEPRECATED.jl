
function AnalysisResultCtrl.upsertAnalysis(
    patient::Patient,
    stay::Stay,
    requestType::ANALYSIS_REQUEST_TYPE,
    requestTime::ZonedDateTime,
    ref::AbstractString,
    encryptionStr::AbstractString,
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

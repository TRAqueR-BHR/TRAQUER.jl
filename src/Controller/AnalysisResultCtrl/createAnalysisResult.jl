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

    PostgresORM.create_entity!(analysisResult,dbconn)

    return analysisResult

end

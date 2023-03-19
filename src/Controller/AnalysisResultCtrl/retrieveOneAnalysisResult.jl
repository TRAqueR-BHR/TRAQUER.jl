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

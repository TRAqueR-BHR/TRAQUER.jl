function AnalysisResultCtrl.retrieveOneAnalysisResult(
    patient::Patient,
    ref::AbstractString,
    encryptionStr::AbstractString,
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

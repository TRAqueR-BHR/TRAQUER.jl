function Custom.getBasicInformationAboutAnalysesInputFile(filePath::String)

    # File modification time
    mod_time = stat(filePath).mtime |> unix2datetime

    _tz = TRAQUERUtil.getTimeZone()

    dfAnalyses = CSV.read(filePath, DataFrame ;delim = ';')

    dfAnalyses.requestTime = map(
        (DATE_DEMANDE,HEURE_DEMANDE) -> TRAQUERUtil.convertStringToZonedDateTime(
            string(DATE_DEMANDE),
            string(HEURE_DEMANDE),
            _tz
         ),
        dfAnalyses[:,:DATE_DEMANDE], dfAnalyses[:,:HEURE_DEMANDE]
    )

    summary = (
        filepath = filePath,
        file_last_modification_time = mod_time,
        number_of_analyses = nrow(dfAnalyses),
        min_analysis_request_date = minimum(dfAnalyses.requestTime),
        max_analysis_request_date = maximum(dfAnalyses.requestTime),
    )

    for (key, value) in pairs(summary)
        println(key, ": ", value)
    end

end

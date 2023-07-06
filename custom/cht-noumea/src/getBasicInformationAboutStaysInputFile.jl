function Custom.getBasicInformationAboutStaysInputFile(filePath::String)

    # File modification time
    mod_time = stat(filePath).mtime |> unix2datetime

    _tz = TRAQUERUtil.getTimeZone()

    dfStays = CSV.read(filePath, DataFrame ;delim = ';')

    dfStays.unitInDate = map(
        (DATE_ENTREE_MVT,HEURE_ENT_MVT) -> TRAQUERUtil.convertStringToZonedDateTime(
            string(DATE_ENTREE_MVT),
            string(HEURE_ENT_MVT),
            _tz
        ),
        dfStays[:,:DATE_ENTREE_MVT],dfStays[:,:HEURE_ENT_MVT]
    )

    summary = (
        filepath = filePath,
        file_last_modification_time = mod_time,
        number_of_stays = nrow(dfStays),
        min_unit_in_date = minimum(dfStays.unitInDate),
        max_unit_in_date = maximum(dfStays.unitInDate),
    )

    for (key, value) in pairs(summary)
        println(key, ": ", value)
    end

end

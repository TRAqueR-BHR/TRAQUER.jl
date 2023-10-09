include("../../../../../test/runtests-prerequisite.jl")

# Cleaning
TRAQUERUtil.createDBConnAndExecute() do dbconn

    "DELETE FROM stay" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM analysis_result" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM infectious_status" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM outbreak" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM contact_exposure" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

end

# Load all stays and analyses in one dataframe
dfStays = DataFrame(
    XLSX.readtable("custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-stays SALIOU.XLSX",1)
    # XLSX.readtable("custom/demo/test/sample-input-data/demo-stays.xlsx",1)
)
dfAnalyses = DataFrame(
    # XLSX.readtable("custom/demo/test/sample-input-data/demo-analyses.xlsx",1)
    XLSX.readtable("custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-analyses SALIOU.XLSX",1)
)

TRAQUERUtil.createDBConnAndExecute() do dbconn
    TRAQUER.Custom.importStays(dfStays,getDefaultEncryptionStr())
end

TRAQUERUtil.createDBConnAndExecute() do dbconn
    TRAQUER.Custom.importAnalyses(dfAnalyses, getDefaultEncryptionStr())
end

# Process the date at different point in time
TRAQUERUtil.createDBConnAndExecute() do dbconn
    ETLCtrl.processNewlyIntegratedData(
        dbconn
        ;forceProcessingTime = ZonedDateTime(
            DateTime("2022-05-10T00:00:00"), TRAQUERUtil.getTimeZone()
        )
    )
end
TRAQUERUtil.createDBConnAndExecute() do dbconn
    ETLCtrl.processNewlyIntegratedData(
        dbconn
        ;forceProcessingTime = ZonedDateTime(
            DateTime("2022-05-15T00:00:00"), TRAQUERUtil.getTimeZone()
        )
    )
end
TRAQUERUtil.createDBConnAndExecute() do dbconn
    ETLCtrl.processNewlyIntegratedData(
        dbconn
        ;forceProcessingTime = ZonedDateTime(
            DateTime("2022-08-01T00:00:00"), TRAQUERUtil.getTimeZone()
        )
    )
end

# ####################### #
# OLD WAY OF DOING THINGS #
# ####################### #

# # Integrate and process the stays and analyses between two given dates
# bounds = (DateTime("2020-01-01T00:00:00"),DateTime("2022-05-10T00:00:00"))
# bounds = (DateTime("2022-05-10T00:00:00"),DateTime("2022-05-15T00:00:00"))
# bounds = (DateTime("2022-05-15T00:00:00"),DateTime("2022-06-01T00:00:00"))
# # Play the following lines after changing the bounds
# dfStaysSelection = filter(
#     s -> s.unit_in_time >= first(bounds) && s.unit_in_time < last(bounds),
#     dfStays
# )
# dfAnalysesSelection = filter(
#     s -> s.request_time >= first(bounds) && s.request_time < last(bounds),
#     dfAnalyses
# )
# TRAQUERUtil.createDBConnAndExecute() do dbconn
#     TRAQUER.Custom.importStays(dfStaysSelection,getDefaultEncryptionStr())
#     TRAQUER.Custom.importAnalyses(dfAnalysesSelection, getDefaultEncryptionStr())
#     ETLCtrl.processNewlyIntegratedData(dbconn)
# end

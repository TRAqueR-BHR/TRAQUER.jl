include("../../../test/runtests-prerequisite.jl")
using CSV, DataFrames
using TRAQUER, TRAQUER.TRAQUERUtil

# Cleaning
MaintenanceCtrl.resetDatabase(resetStays = false)

# Load all stays and analyses in one dataframe
# dfStays = CSV.read(
#     "/home/traquer/DATA/pending/dxcare-3mois.csv",
#     DataFrame
#     ;delim = ';'
# )
# dfAnalyses = CSV.read(
#     "/home/traquer/DATA/pending/inlog-3mois.csv",
#     DataFrame
#     ;delim = ';'
# )


@time TRAQUER.Custom.importStays(dfStays, getDefaultEncryptionStr()) # 1000 lines in 130s with 4 workers
                                                                     # 1000 lines in 380s with 1 worker
@time TRAQUER.Custom.importAnalyses(
    "/home/traquer/DATA/pending/inlog-3mois.csv",
    "/home/traquer/CODE/TRAQUER.jl/tmp/problems",
    getDefaultEncryptionStr(),
    ;maxNumberOfLinesToIntegrate = 10
)

# Process the date at different point in time
TRAQUERUtil.createDBConnAndExecute() do dbconn
    SchedulerCtrl.processNewlyIntegratedData(
        dbconn
        ;forceProcessingTime = ZonedDateTime(
            DateTime("2022-05-10T00:00:00"), TRAQUERUtil.getTimeZone()
        )
    )
end
TRAQUERUtil.createDBConnAndExecute() do dbconn
    SchedulerCtrl.processNewlyIntegratedData(
        dbconn
        ;forceProcessingTime = ZonedDateTime(
            DateTime("2022-05-15T00:00:00"), TRAQUERUtil.getTimeZone()
        )
    )
end
TRAQUERUtil.createDBConnAndExecute() do dbconn
    SchedulerCtrl.processNewlyIntegratedData(
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
#     SchedulerCtrl.processNewlyIntegratedData(dbconn)
# end

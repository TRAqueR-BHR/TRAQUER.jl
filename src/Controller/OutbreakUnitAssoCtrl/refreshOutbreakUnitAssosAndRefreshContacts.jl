function OutbreakUnitAssoCtrl.refreshOutbreakUnitAssosAndRefreshContacts(
    dbconn::LibPQ.Connection,
    ;hintOnWhatOutbreakUnitAssosToSelect::Union{Missing,Vector{Stay}} = missing
)
    outbreaks = "SELECT o.* FROM outbreak o" |>
    n -> PostgresORM.execute_query_and_handle_result(n, Outbreak, missing, false, dbconn)

    # TODO: Restrict the outbreaks based on the hint
    OutbreakUnitAssoCtrl.refreshOutbreakUnitAssos.(outbreaks, dbconn)
    ContactExposureCtrl.refreshExposuresAndContactStatuses.(outbreaks, dbconn)
end

function OutbreakUnitAssoCtrl.refreshOutbreakUnitAssosAndRefreshContacts(
    outbreak::Outbreak, dbconn::LibPQ.Connection
)
    OutbreakUnitAssoCtrl.refreshOutbreakUnitAssos(outbreak, dbconn)
    ContactExposureCtrl.refreshExposuresAndContactStatuses(outbreak, dbconn)
end

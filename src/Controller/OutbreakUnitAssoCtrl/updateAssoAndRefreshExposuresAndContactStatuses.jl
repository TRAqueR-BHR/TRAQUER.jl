function OutbreakUnitAssoCtrl.updateAssoAndRefreshExposuresAndContactStatuses(
    asso::OutbreakUnitAsso, dbconn::LibPQ.Connection
)

    PostgresORM.update_entity!(asso,dbconn)
    ContactExposureCtrl.refreshExposuresAndContactStatuses(asso, dbconn)

end

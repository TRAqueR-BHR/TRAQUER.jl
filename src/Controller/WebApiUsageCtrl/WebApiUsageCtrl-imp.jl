function WebApiUsageCtrl.logAPIUsage(
    appuser::Appuser,
    apiURL::String,
    inTime::ZonedDateTime,
    outTime::ZonedDateTime
)

    createDBConnAndExecute() do dbconn
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            inTime,
            outTime,
            dbconn
        )
    end

end

function WebApiUsageCtrl.logAPIUsage(
    appuser::Appuser,
    apiURL::String,
    inTime::ZonedDateTime,
    outTime::ZonedDateTime,
    dbconn::LibPQ.Connection
)

    apiUsage = WebApiUsage(
        user = appuser,
        inTime = inTime,
        outTime = outTime,
        apiUrl = apiURL,
    )

    PostgresORM.create_entity!(apiUsage, dbconn)

end

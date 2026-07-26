"""
    getActiveStayMonitoringScopes(
        dbconn::LibPQ.Connection,
    )::Vector{StayMonitoringScope}

Return the stay monitoring scopes that are still active, i.e. the ones whose
`deactivationTime` is missing.
"""
function ETLCtrl.ScopeCtrl.getActiveStayMonitoringScopes(
    dbconn::LibPQ.Connection,
)::Vector{StayMonitoringScope}
    # Active scopes are the ones that have not been deactivated yet.
    queryString = "
        SELECT sms.*
        FROM etl.stay_monitoring_scope sms
        WHERE sms.deactivation_time IS NULL
        ORDER BY sms.activation_time, sms.id
    "

    # Retrieve the matching ORM entities without complex properties.
    activeStayMonitoringScopes = PostgresORM.execute_query_and_handle_result(
        queryString,
        StayMonitoringScope,
        Any[],
        false,
        dbconn,
    )

    return activeStayMonitoringScopes
end

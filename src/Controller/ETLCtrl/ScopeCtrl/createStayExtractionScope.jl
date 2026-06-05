function ETLCtrl.ScopeCtrl.createStayExtractionScope(
    stayMonitoringScope::StayMonitoringScope,
    dbconn::LibPQ.Connection
)::StayExtractionScope

    if ismissing(stayMonitoringScope.id)
        throw(ArgumentError("stayMonitoringScope must be persisted before creating a stay extraction scope"))
    end

    stayExtractionScope = ETLCtrl.ScopeCtrl.buildStayExtractionScope(
        stayMonitoringScope,
        dbconn
    )

    PostgresORM.create_entity!(stayExtractionScope, dbconn)

    return stayExtractionScope

end

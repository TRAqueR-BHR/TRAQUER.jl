function ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes(
    dbconn::LibPQ.Connection,
)
    infectiousStatusesAtRisk = InfectiousStatusCtrl.getCurrentInfectiousStatusesAtRisk(dbconn)
    monitoringScopes = Vector{StayMonitoringScope}()
    for infectiousStatus in infectiousStatusesAtRisk
        scopes = ETLCtrl.ScopeCtrl.createStayMonitoringScopeListIfNotExist(
            infectiousStatus,
            dbconn
        )
        if !isnothing(scopes)
            append!(monitoringScopes, scopes)
        end
    end
    return monitoringScopes
end

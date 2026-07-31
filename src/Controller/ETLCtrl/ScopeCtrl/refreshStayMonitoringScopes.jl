function ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes(
    dbconn::LibPQ.Connection,
)   
    # Retrieve infectious statuses that are worth creating monitoring scopes for
    infectiousStatusesAtRisk = 
        InfectiousStatusCtrl.getInfectiousStatusesAtRiskForStayMonitoringScopeRefresh(dbconn)
    
    infectiousStatusesAtRiskIds = getproperty.(infectiousStatusesAtRisk, :id)

    # Deactivate obsolete monitoring scopes
    existingStayMonitoringScopes = ETLCtrl.ScopeCtrl.getActiveStayMonitoringScopes(dbconn)
    for stayMonitoringScope in existingStayMonitoringScopes
        
        if stayMonitoringScope.justifyingInfectiousStatus.id ∉ infectiousStatusesAtRiskIds
            
            stayMonitoringScope.deactivationTime = now(TRAQUERUtil.getTimeZone())
            PostgresORM.update_entity!(
                stayMonitoringScope,
                dbconn
            )
        end
    end

    # Then upsert active monitoring scopes
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

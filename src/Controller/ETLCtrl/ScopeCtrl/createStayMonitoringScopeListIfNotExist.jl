function ETLCtrl.ScopeCtrl.createStayMonitoringScopeListIfNotExist(
    infectiousStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)::Union{Nothing,Vector{StayMonitoringScope}}

    stayMonitoringScopeList = ETLCtrl.ScopeCtrl.buildStayMonitoringScopeList(
        infectiousStatus,
        dbconn
    )

    result = Vector{StayMonitoringScope}()

    if isnothing(stayMonitoringScopeList)
        return nothing
    end

    for stayMonitoringScope in stayMonitoringScopeList

        # Only create the stay monitoring scope if it does not already exist in the database
        existingStayMonitoringScope = PostgresORM.retrieve_one_entity(
            StayMonitoringScope(
                justifyingInfectiousStatus = infectiousStatus,
                monitoredUnit = stayMonitoringScope.monitoredUnit,
                monitoredPatient = stayMonitoringScope.monitoredPatient,
                periodOiStartTime = stayMonitoringScope.periodOiStartTime,
                periodOiEndTime = stayMonitoringScope.periodOiEndTime,
            ),
            false,
            dbconn
        )

        if !ismissing(existingStayMonitoringScope)
            push!(result, existingStayMonitoringScope)
            continue
        end

        PostgresORM.create_entity!(stayMonitoringScope, dbconn)
        push!(result, stayMonitoringScope)
    end

    return result

end

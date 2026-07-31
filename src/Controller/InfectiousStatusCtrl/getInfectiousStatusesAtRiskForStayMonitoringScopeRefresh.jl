"""
    getInfectiousStatusesAtRiskForStayMonitoringScopeRefresh(
        dbconn::LibPQ.Connection,
    )
We need a custom function for the StayMonitoringScope because during refresh,
to anticipate that the infectious status will be confirmed.

TODO replace InfectiousStatusCtrl.getCurrentInfectiousStatusesAtRisk(dbconn) call 
into a dedicated logic.
"""
function InfectiousStatusCtrl.getInfectiousStatusesAtRiskForStayMonitoringScopeRefresh(
    dbconn::LibPQ.Connection,
)::Vector{InfectiousStatus}


    activeInfectiousStatuses = InfectiousStatusCtrl.getCurrentInfectiousStatusesAtRisk(dbconn)

    result::Vector{InfectiousStatus} = []
    append!(result, activeInfectiousStatuses)
    
    for infectiousStatus in activeInfectiousStatuses
        # Check for this infectiousAgent + patient if there are later statuses
        # 
        infectiousStatusesAfterActiveStatus = InfectiousStatusCtrl.getInfectiousStatusesAfterTime(
            infectiousStatus.patient,
            infectiousStatus.refTime,
            false,
            dbconn
            ;statusesOfInterest = INFECTIOUS_STATUS_TYPES_AT_RISK,
            infectiousAgentsOfInterest = [infectiousStatus.infectiousAgent]
        )

        append!(result, infectiousStatusesAfterActiveStatus)


    end

    return result
end
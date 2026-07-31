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

    return InfectiousStatusCtrl.getCurrentInfectiousStatusesAtRisk(dbconn)
end
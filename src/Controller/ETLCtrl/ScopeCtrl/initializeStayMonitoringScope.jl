function ETLCtrl.ScopeCtrl.initializeStayMonitoringScope(
    infectiousStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)

    # Check that the patient is actually at risk.
    if infectiousStatus.infectiousStatus ∉ INFECTIOUS_STATUS_TYPES_AT_RISK
        return nothing
    end

    # TODO: create the stay monitoring scope and the corresponding extraction scope.
    return nothing

end

function ETLCtrl.ScopeCtrl.initializeStayMonitoringScope(
    infectiousStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)::Union{Nothing,StayMonitoringScope}

    # Check that the patient is actually at risk.
    if infectiousStatus.infectiousStatus ∉ INFECTIOUS_STATUS_TYPES_AT_RISK
        return nothing
    end

    # Initialize the properties to missing
    patientIds = infectiousStatus.patient.id
    periodOiStartTime = missing
    periodOiEndTime = missing
    deactivationCondition = missing
    activationTime = missing
    deactivationTime = missing
    justification = missing

    # If patient is carrier we want to get whole his stays (even the ones before this status
    # was identified) => leave the stay monitoring scope open (i.e., with missing start and
    # end time)


    # For contact and suspicion we want to get only the stays of this hospitalization

    # TODO: create the stay monitoring scope and the corresponding extraction scope.
    return nothing

end

# TODO: Unit test
function InfectiousStatusCtrl.getTimeWherePatientBecameCarrierOrSuspicion(
    patient::Patient,
    infectiousAgent::InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY,
    stay::Stay,
    dbconn::LibPQ.Connection
)::Union{ZonedDateTime, Missing}

    carrierOrSuspicionStatuses = InfectiousStatusCtrl.getInfectiousStatusesOfInterestOverPeriod(
        patient,
        infectiousAgent,
        [InfectiousStatusType.carrier, InfectiousStatusType.suspicion],
        stay.inTime,
        if !ismissing(stay.outTime) stay.outTime else now(TRAQUERUtil.getTimeZone()) end,
        false, # retrieveComplexProps::Bool,
        dbconn
    )

    if isempty(carrierOrSuspicionStatuses)
        return missing
    else
        first(carrierOrSuspicionStatuses).refTime
    end

end

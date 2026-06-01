function _TestUtils.createDummyCarrierInfectiousStatus(
    patient::Patient,
    dbconn::LibPQ.Connection
    ;infectiousAgent = InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
    refTime = ZonedDateTime(now(), TRAQUERUtil.getTimeZone()),
    isConfirmed = true
)::InfectiousStatus

    refTime = ZonedDateTime(now(), TRAQUERUtil.getTimeZone())

    infectiousStatus = InfectiousStatus(
        patient = patient,
        infectiousAgent = infectiousAgent,
        infectiousStatus = InfectiousStatusType.carrier,
        refTime = refTime,
        isConfirmed = isConfirmed
    )

    InfectiousStatusCtrl.upsert!(
        infectiousStatus,
        dbconn;
        createEventForStatus = false
    )

    return infectiousStatus

end

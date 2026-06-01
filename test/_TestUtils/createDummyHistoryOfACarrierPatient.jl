function _TestUtils.createDummyHistoryOfACarrierPatient(
    dbconn::LibPQ.Connection;
    numberOfUnits::Integer = 10,
    numberOfStays::Integer = 10,
    firstHospitalizationInTime::ZonedDateTime = now(TRAQUERUtil.getTimeZone()) - Day(30),
)::NamedTuple{(:patient, :stays, :infectiousStatus)}

    patient = _TestUtils.createDummyPatient(dbconn)
    units = _TestUtils.createDummyUnits(
        dbconn;
        numberOfUnits = numberOfUnits
    )
    stays = _TestUtils.createDummyStays(
        patient,
        units,
        dbconn;
        firstHospitalizationInTime = firstHospitalizationInTime,
        numberOfStays = numberOfStays
    )
    refTime = if length(stays) >= 3
        stays[3].inTime + (stays[3].outTime - stays[3].inTime) / 2
    elseif !isempty(stays)
        stays[end].inTime + (stays[end].outTime - stays[end].inTime) / 2
    else
        firstHospitalizationInTime
    end

    infectiousStatus = _TestUtils.createDummyCarrierInfectiousStatus(
        patient,
        dbconn;
        refTime = refTime
    )

    return (
        patient = patient,
        stays = stays,
        infectiousStatus = infectiousStatus,
    )

end

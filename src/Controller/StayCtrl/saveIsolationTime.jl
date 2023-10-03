function StayCtrl.saveIsolationTime(
    patient::Patient,
    isolationTime::ZonedDateTime,
    dbconn::LibPQ.Connection
)

    # Look for the stay that contains the event time
    stay = StayCtrl.retrieveOneStayContainingDateTime(
        patient,
        isolationTime,
        dbconn
    )

    if ismissing(stay)
        error("No stay found for patient[$(patient.id)] at time[$(isolationTime)]")
    end

    stay.isolationTime = isolationTime

    PostgresORM.update_entity!(stay, dbconn)

    return stay

end

function StayCtrl.saveIsolationTime(
    eventRequiringAttention::EventRequiringAttention,
    isolationTime::ZonedDateTime,
    dbconn::LibPQ.Connection
)

    # Check that we have the id of the patient loaded
    if ismissing(eventRequiringAttention.infectiousStatus.patient)
        eventRequiringAttention.infectiousStatus = PostgresORM.retrieve_one_entity(
            InfectiousStatus(id = eventRequiringAttention.infectiousStatus.id),
            false,
            dbconn
        )
    end

    if ismissing(eventRequiringAttention.infectiousStatus.patient)
        error("eventRequiringAttention.infectiousStatus.patient is missing")
    end


    return StayCtrl.saveIsolationTime(
        eventRequiringAttention.infectiousStatus.patient,
        isolationTime,
        dbconn
    )

end

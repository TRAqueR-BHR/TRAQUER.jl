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

    # If no stay is found throw a custom error, so that we can warn the user in a friendly way
    if ismissing(stay)
        throw(
            NoStayFoundError(
                getTranslation("no_stay_found_at_time")
            )
        )
    end

    stay.isolationTime = isolationTime

    PostgresORM.update_entity!(stay, dbconn)

    # Refresh the outbreaks involving the patient as carrier
    outbreaks = "
        SELECT DISTINCT o.*
        FROM outbreak o
        JOIN outbreak_infectious_status_asso oisa
          ON o.id = oisa.outbreak_id
        JOIN infectious_status ist
          ON oisa.infectious_status_id = ist.id
        WHERE ist.patient_id = \$1
        AND ist.infectious_status = 'carrier'" |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            Outbreak,
            [patient.id],
            false,
            dbconn
        )

    ContactExposureCtrl.refreshExposuresAndContactStatuses.(outbreaks, dbconn)

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

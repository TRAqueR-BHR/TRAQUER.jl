function MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures(
    dbconn::LibPQ.Connection
)

    # TODO: Add a security with a configuration to prevent invoking it by mistake

    "DELETE FROM infectious_status" |> # also deletes entries in 'event_requiring_attention'
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM outbreak" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM contact_exposure" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "UPDATE stay SET sys_processing_time = NULL, isolation_time = NULL" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "UPDATE analysis_result SET sys_processing_time = NULL" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM misc.max_processing_time" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    return true

end

function MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures(
    patient::Patient,
    dbconn::LibPQ.Connection
)

    # TODO: Add a security with a configuration to prevent invoking it by mistake

    "DELETE FROM infectious_status WHERE patient_id = \$1" |>
    n -> PostgresORM.execute_plain_query(n,[patient.id],dbconn)

    "DELETE FROM contact_exposure
    WHERE carrier_id = \$1
      OR contact_id = \$1 " |>
    n -> PostgresORM.execute_plain_query(n,[patient.id],dbconn)

    "UPDATE analysis_result
    SET sys_processing_time = null
    FROM analysis_result ar
    WHERE ar.id = analysis_result.id
      AND ar.patient_id = \$1" |>
    n -> PostgresORM.execute_plain_query(n, [patient.id], dbconn)

    "UPDATE stay
    SET sys_processing_time = null
    FROM stay s
    WHERE s.id = stay.id
        AND s.patient_id = \$1" |>
    n -> PostgresORM.execute_plain_query(n, [patient.id], dbconn)

    return true

end

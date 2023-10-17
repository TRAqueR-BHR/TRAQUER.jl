function InfectiousStatusCtrl.delete(infectiousStatus::InfectiousStatus, dbconn::LibPQ.Connection)

    DeletedInfectiousStatusCtrl.create(
        infectiousStatus,
        dbconn
    )

    PostgresORM.delete_entity(infectiousStatus, dbconn)

    # Update patient current status
    InfectiousStatusCtrl.updateCurrentStatus(infectiousStatus.patient, dbconn)

    # Refresh the outbreaks involving the patient
    # Eg. If the deleted infectious status was a 'not_at_risk' following a 'carrier' status
    #     then we have more exposures
    outbreaks = "
        SELECT DISTINCT o.*
        FROM outbreak o
        JOIN outbreak_infectious_status_asso oisa
          ON o.id = oisa.outbreak_id
        JOIN infectious_status ist
          ON oisa.infectious_status_id = ist.id
        WHERE ist.patient_id = \$1" |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            Outbreak,
            [infectiousStatus.patient.id],
            false,
            dbconn
        )

    ContactExposureCtrl.refreshExposuresAndContactStatuses.(outbreaks, dbconn)

    return infectiousStatus

end

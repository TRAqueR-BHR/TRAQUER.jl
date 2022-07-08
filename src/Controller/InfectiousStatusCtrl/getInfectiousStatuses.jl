function InfectiousStatusCtrl.getInfectiousStatuses(
    patient::Patient,
    dbconn::LibPQ.Connection
)

    "SELECT ist.*
    FROM infectious_status ist
    WHERE ist.patient_id = \$1
    ORDER BY ist.ref_time" |>
    n -> PostgresORM.execute_query_and_handle_result(
        n,InfectiousStatus,[patient.id],false,dbconn)

end

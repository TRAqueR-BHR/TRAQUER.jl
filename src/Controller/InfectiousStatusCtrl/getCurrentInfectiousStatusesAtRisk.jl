function InfectiousStatusCtrl.getCurrentInfectiousStatusesAtRisk(
    dbconn::LibPQ.Connection,
)::Vector{InfectiousStatus}
    queryString = "
        SELECT ist.*
        FROM infectious_status ist
        WHERE ist.is_current = true
          AND ist.infectious_status = ANY(\$1)
        ORDER BY ist.patient_id, ist.infectious_agent, ist.ref_time
    "
    queryArgs = [INFECTIOUS_STATUS_TYPES_AT_RISK]

    infectiousStatuses = PostgresORM.execute_query_and_handle_result(
        queryString,
        InfectiousStatus,
        queryArgs,
        false,
        dbconn,
    )

    return infectiousStatuses
end

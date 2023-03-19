function OutbreakCtrl.getOutbreakUnitAssosFromInfectiousStatus(
    infectiousStatus::InfectiousStatus,
    retrieveComplexProperties::Bool,
    dbconn::LibPQ.Connection
)::Vector{OutbreakUnitAsso}

    assos = "
        SELECT oisa.*
        FROM infectious_status _is
        JOIN outbreak_infectious_status_asso oisa
            ON _is.id = oisa.infectious_status_id
        WHERE _is.id = \$1
    " |>
        n -> execute_query_and_handle_result(
                n, OutbreakUnitAsso, [infectiousStatus.id], retrieveComplexProperties, dbconn) |>
        n -> sort!(
            n
            ;lt = (a, b) -> abs(a.refTime - eventRefTime) < abs(b.refTime - eventRefTime)
        )

    return assos

end

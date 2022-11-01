function OutbreakCtrl.getOutbreakFromInfectiousStatus(
    infectiousStatus::InfectiousStatus, retrieveComplexProperties::Bool, dbconn::LibPQ.Connection
)::Union{Missing, Outbreak}

    outbreak::Union{Missing, Outbreak} = "
        SELECT o.*
        FROM infectious_status _is
        JOIN outbreak_infectious_status_asso oisa
        ON _is.id = oisa.infectious_status_id
        JOIN outbreak o
        ON o.id = oisa.outbreak_id
        WHERE _is.id = \$1
    " |> n -> execute_query_and_handle_result(
                n, Outbreak, [infectiousStatus.id], retrieveComplexProperties, dbconn
      ) |> n -> if isempty(n) missing else first(n) end

    return outbreak

end

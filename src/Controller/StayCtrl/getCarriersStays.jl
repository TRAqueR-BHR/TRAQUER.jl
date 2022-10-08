function StayCtrl.getCarriersStays(
    outbreakConfigUnitAsso::OutbreakConfigUnitAsso,
    dbconn::LibPQ.Connection
)::Vector{Stay}

    # Get the outbreak
    outbreak = "
        SELECT o.*
        FROM outbreak_config_unit_asso ocua
        JOIN outbreak_config oc
          ON oc.id = ocua.outbreak_config_id
        JOIN outbreak o
          ON o.config_id = oc.id
        WHERE ocua.id = \$1" |>
            n -> PostgresORM.execute_query_and_handle_result(
                n, Outbreak, [outbreakConfigUnitAsso.id], false, dbconn) |> first

    # Select all the carrier infectious statuses of this outbreak
    infectiousStatuses = "
        SELECT ist.*
        FROM outbreak_infectious_status_asso oiss
        JOIN infectious_status ist
          ON ist.id = oiss.infectious_status_id
        WHERE ist.infectious_status = 'carrier'
        AND oiss.outbreak_id = \$1" |>
        n -> PostgresORM.execute_query_and_handle_result(n, InfectiousStatus, [outbreak.id], false, dbconn)

    stays = Stay[]
    for is in infectiousStatuses
        push!(
            stays,
            StayCtrl.getStaysWherePatientAtRisk(is, dbconn)...
        )
    end

    return stays

end

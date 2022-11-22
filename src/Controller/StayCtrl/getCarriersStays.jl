function StayCtrl.getCarriersStays(
    outbreakUnitAsso::OutbreakUnitAsso,
    dbconn::LibPQ.Connection
)::Vector{Stay}

    # Get the outbreak
    outbreak = "
        SELECT o.*
        FROM outbreak_unit_asso oua
        JOIN outbreak o
          ON o.id = oua.outbreak_id
        WHERE oua.id = \$1" |>
            n -> PostgresORM.execute_query_and_handle_result(
                n, Outbreak, [outbreakUnitAsso.id], false, dbconn) |> first

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
        staysWherePatientAtRisk = StayCtrl.getStaysWherePatientAtRisk(is, dbconn)
        filter!(s -> s.unit.id == outbreakUnitAsso.unit.id, staysWherePatientAtRisk)
        push!(
            stays,
            staysWherePatientAtRisk...
        )
    end

    return stays

end

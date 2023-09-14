function StayCtrl.getCarriersOrContactsStays(
    outbreakUnitAsso::OutbreakUnitAsso,
    infectiousStatusType::INFECTIOUS_STATUS_TYPE,
    dbconn::LibPQ.Connection
)::Vector{Stay}

    # Check that the outbreakUnitAsso is properly loaded
    if ismissing(outbreakUnitAsso.unit)
        outbreakUnitAsso = PostgresORM.retrieve_one_entity(
            OutbreakUnitAsso(id = outbreakUnitAsso.id),
            false,
            dbconn)
    end

    # Get the outbreak
    outbreak = "
        SELECT o.*
        FROM outbreak_unit_asso oua
        JOIN outbreak o
          ON o.id = oua.outbreak_id
        WHERE oua.id = \$1" |>
            n -> PostgresORM.execute_query_and_handle_result(
                n, Outbreak, [outbreakUnitAsso.id], false, dbconn) |> first

    # Select all the carrier/contact infectious statuses of this outbreak
    infectiousStatuses = "
        SELECT ist.*
        FROM outbreak_infectious_status_asso oiss
        JOIN infectious_status ist
          ON ist.id = oiss.infectious_status_id
        WHERE ist.infectious_status = \$2
        AND oiss.outbreak_id = \$1" |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            InfectiousStatus,
            [outbreak.id, infectiousStatusType],
            false,
            dbconn)

    # Add the stays in the unit
    # NOTE: If we are looking for the contact stays, maybe we would only want the stays for
    #       which we can find a contactExposure indeed `StayCtrl.getStaysWherePatientAtRisk`
    #       returns all the stays where the patient was at risk even if it has no exposure
    #       in that unit. Nevertheless, in the case where the contact infectious status has
    #       been created manually, we dont have a contact exposure
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

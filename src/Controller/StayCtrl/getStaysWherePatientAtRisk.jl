function StayCtrl.getStaysWherePatientAtRisk(
    atRiskStatus::InfectiousStatus,
    dbconn::LibPQ.Connection)::Vector{Stay}

    # Look for an infectious status 'not_at_risk' after the 'carrier' ref. time for this
    # same infectious agent. It will allow to exclude the stays that started after the
    # ref. time of this 'not_at_risk' status
    notAtRiskStatus = "
        SELECT ist.*
        FROM infectious_status ist
        WHERE ist.patient_id = \$1
            AND ist.infectious_agent = \$2
            AND ist.infectious_status = 'not_at_risk'
            AND ist.ref_time > \$3
        ORDER BY ist.ref_time
        LIMIT 1
        " |>
        n -> PostgresORM.execute_query_and_handle_result(
                n,
                InfectiousStatus,
                [
                    atRiskStatus.patient.id,
                    atRiskStatus.infectiousAgent,
                    atRiskStatus.refTime
                ],
                false,
                dbconn
            ) |> n -> if isempty(n) missing else first(1) end

    # ################################################################################### #
    # Get all stays of the carrier and keep the ones that can generate an exposure        #
    # ################################################################################### #
    queryString = "
       SELECT s.*
       FROM stay s
       WHERE s.patient_id = \$1
       ORDER BY s.in_time
    "
    queryArgs = [atRiskStatus.patient.id]
    atRiskStays = PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        queryArgs,
        false,
        dbconn)

    # Only keep the stays that can generate exposures
    filter!(
        stay -> ContactExposureCtrl.canGenerateContactExposures(
                    stay,
                    atRiskStatus,
                    notAtRiskStatus
                ),
        atRiskStays
    )

    return atRiskStays

end

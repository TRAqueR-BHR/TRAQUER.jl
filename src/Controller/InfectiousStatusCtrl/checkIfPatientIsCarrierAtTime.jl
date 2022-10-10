function InfectiousStatusCtrl.checkIfPatientIsCarrierAtTime(
    patient::Patient,
    infectiousAgent::INFECTIOUS_AGENT_CATEGORY,
    timeOfInterest::ZonedDateTime,
    dbconn::LibPQ.Connection
)

    @info "[patient.id, infectiousAgent]" [patient.id, infectiousAgent]

    # Get all the 'carrier' and 'not_at_risk' statuses
    # NOTE: But anyway, there should be no case where a 'carrier' transition to 'contact'
    statuses = "SELECT ist.*
    FROM infectious_status ist
    WHERE ist.patient_id = \$1
      AND ist.infectious_agent = \$2
      AND ist.infectious_status IN ('carrier','not_at_risk')
      AND ist.is_confirmed = 't' -- This shouldnt do much difference
    ORDER BY ist.ref_time" |>
    n -> PostgresORM.execute_query_and_handle_result(
        n, InfectiousStatus, [patient.id, infectiousAgent], false, dbconn)

    if isempty(statuses)
        return false
    end

    # Get the closest status
    closestStatus = sort!(statuses, by = x -> abs(x.refTime - timeOfInterest)) |> first

    if closestStatus.infectiousStatus == InfectiousStatusType.carrier
        return true
    else
        return false
    end

end

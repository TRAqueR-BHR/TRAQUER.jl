function InfectiousStatusCtrl.getInfectiousStatusAtTime(
    patient::Patient,
    infectiousAgent::InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY,
    timeOfInterest::ZonedDateTime,
    retrieveComplexProps::Bool,
    dbconn::LibPQ.Connection
    ;statusesOfInterest::Union{Missing,Vector{InfectiousStatusType.INFECTIOUS_STATUS_TYPE}} = missing
)::Union{Missing, InfectiousStatus}

    # Select the infectious agent with a ref time before the time of interest
    queryString = "
    SELECT ist.*
    FROM infectious_status ist
    WHERE ist.patient_id = \$1
      AND ist.ref_time <= \$2
      AND ist.infectious_agent = \$3"
    queryParams = [patient.id, timeOfInterest, infectiousAgent]

    if !ismissing(statusesOfInterest) && !isempty(statusesOfInterest)
        queryString *= "
            AND ist.infectious_status = ANY(\$4) "
        push!(queryParams,statusesOfInterest)
    end
    queryString *= "
        ORDER BY ist.ref_time "

    statuses = PostgresORM.execute_query_and_handle_result(
        queryString, InfectiousStatus, queryParams, retrieveComplexProps, dbconn)

    if isempty(statuses)
        return missing
    end

    # Get the closest status
    closestStatus = sort!(statuses, by = x -> abs(x.refTime - timeOfInterest)) |> first

    return closestStatus

end
!

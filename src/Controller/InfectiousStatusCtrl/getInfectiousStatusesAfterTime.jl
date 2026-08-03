function InfectiousStatusCtrl.getInfectiousStatusesAfterTime(
    patient::Patient,
    timeOfInterest::ZonedDateTime,
    retrieveComplexProps::Bool,
    dbconn::LibPQ.Connection
    ;statusesOfInterest::Union{Missing,Vector{InfectiousStatusType.INFECTIOUS_STATUS_TYPE}} = missing,
    infectiousAgentsOfInterest::Union{Missing,Vector{InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}} = missing
)::Vector{InfectiousStatus}

    # Select the infectious agent with a ref time before the time of interest
    queryString = "
    SELECT ist.*
    FROM infectious_status ist
    WHERE ist.patient_id = \$1
      AND ist.ref_time > \$2
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

    # Order to put most recent first
    result = sort!(statuses, by = x -> abs(x.refTime - timeOfInterest))

    return result

end

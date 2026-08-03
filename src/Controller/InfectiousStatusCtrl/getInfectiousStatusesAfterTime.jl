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
    "
    
    queryParams = [patient.id, timeOfInterest]

    # Handle optional infectiousAgentsOfInterest
    if !ismissing(infectiousAgentsOfInterest)
        push!(queryParams, infectiousAgentsOfInterest)
        queryString *= "
            AND ist.infectious_agent = ANY(\$$(length(queryParams))) "
    end
      
    # Handle optional statusesOfInterest
    if !ismissing(statusesOfInterest) && !isempty(statusesOfInterest)
        push!(queryParams,statusesOfInterest)
        queryString *= "
            AND ist.infectious_status = ANY(\$$(length(queryParams))) "
    end

    queryString *= "
        ORDER BY ist.ref_time "

    statuses = PostgresORM.execute_query_and_handle_result(
        queryString, InfectiousStatus, queryParams, retrieveComplexProps, dbconn)

    # Order to put most recent first
    result = sort!(statuses, by = x -> abs(x.refTime - timeOfInterest))

    return result

end

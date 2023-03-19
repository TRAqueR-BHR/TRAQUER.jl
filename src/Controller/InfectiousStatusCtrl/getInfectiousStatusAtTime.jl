function InfectiousStatusCtrl.getInfectiousStatusAtTime(
    patient::Patient,
    timeOfInterest::ZonedDateTime,
    retrieveComplexProps::Bool,
    dbconn::LibPQ.Connection
    ;statusesOfInterest::Union{Missing,Vector{InfectiousStatusType.INFECTIOUS_STATUS_TYPE}} = missing
)::Union{Nothing, InfectiousStatus}

    queryString = "
    SELECT ist.*
    FROM infectious_status ist
    WHERE ist.patient_id = \$1
      AND ist.ref_time <= \$2"
    queryParams = [patient.id, timeOfInterest]

    if !ismissing(statusesOfInterest) && !isempty(statusesOfInterest)
        queryString *= " AND ist.infectious_status =     ANY(\$3) "
        push!(queryParams,statusesOfInterest)
    end
    queryString *= " ORDER BY ist.ref_time "

    statuses = PostgresORM.execute_query_and_handle_result(
        queryString, InfectiousStatus, queryParams, retrieveComplexProps, dbconn)

    if isempty(statuses)
        return
    end

    # Get the closest status
    closestStatus = sort!(statuses, by = x -> abs(x.refTime - timeOfInterest)) |> first

    return closestStatus

end
!

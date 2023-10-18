# TODO: Unit test
function InfectiousStatusCtrl.getInfectiousStatusesOfInterestOverPeriod(
    patient::Patient,
    infectiousAgent::InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY,
    statusesOfInterest::Vector{InfectiousStatusType.INFECTIOUS_STATUS_TYPE},
    lowerLimit::ZonedDateTime,
    upperLimit::ZonedDateTime,
    retrieveComplexProps::Bool,
    dbconn::LibPQ.Connection
)::Vector{InfectiousStatus}

    # Select the infectious agent with a ref time before the time of interest
    queryString = "
    SELECT ist.*
    FROM infectious_status ist
    WHERE ist.patient_id = \$1
      AND ist.infectious_agent = \$2
      AND ist.infectious_status = ANY(\$3)
      AND ist.ref_time >= \$4
      AND ist.ref_time <= \$5
      ORDER BY ist.ref_time
      "
    queryParams = [patient.id, infectiousAgent,statusesOfInterest,lowerLimit, upperLimit]

    statuses = PostgresORM.execute_query_and_handle_result(
        queryString, InfectiousStatus, queryParams, retrieveComplexProps, dbconn)

    return statuses

end

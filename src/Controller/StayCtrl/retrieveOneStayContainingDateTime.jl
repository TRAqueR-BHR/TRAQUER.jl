function StayCtrl.retrieveOneStayContainingDateTime(
    patient::Patient,
    zonedDateTime::ZonedDateTime,
    dbconn::LibPQ.Connection)

    # Start by retrieving all the stays where the in_date is less than or
    #   equal to the given _date
    # NOTE: Do not query on the out date because a stay may not have an
    #         out date
    queryString = "
            SELECT s.* FROM stay s
            INNER JOIN patient p
                ON s.patient_id = p.id
            WHERE p.id = \$1
                AND s.in_time <= \$2
                "

    queryArgs = []
    push!(queryArgs, patient.id)
    push!(queryArgs, zonedDateTime)

    stays =
        PostgresORM.execute_query_and_handle_result(queryString,
                                                    Stay,
                                                    queryArgs,
                                                    false, # complex props
                                                    dbconn)

    # Put the stay closest to the target date first
    sort!(stays, by = x -> abs(zonedDateTime - x.inTime))

    if isempty(stays)
        return missing
    else
        return first(stays)
    end
end

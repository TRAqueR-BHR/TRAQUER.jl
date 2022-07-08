function StayCtrl.retrieveOneStay(patient::Patient,
                                  inTime::ZonedDateTime,
                                  dbconn::LibPQ.Connection)
    queryString = "
            SELECT s.* FROM stay s
            INNER JOIN patient p
                ON s.patient_id = p.id
            WHERE p.id = \$1
                AND s.in_date = \$2 -- targets the right partition
                AND s.in_time = \$3"

    queryArgs = []
    push!(queryArgs, patient.id)
    push!(queryArgs, Dates.Date(inTime))
    push!(queryArgs, inTime)

    stays = PostgresORM.execute_query_and_handle_result(queryString,
                                                Stay,
                                                queryArgs,
                                                false, # complex props
                                                dbconn)
    if isempty(stays)
        return missing
    else
        return first(stays)
    end
end

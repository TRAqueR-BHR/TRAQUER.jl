function StayCtrl.createStayIfNotExist(patient::Patient,
                                       unit::Unit,
                                       inDateTime::ZonedDateTime,
                                       outDateTime::Union{Missing,ZonedDateTime},
                                       hospitalizationDate::Date,
                                       dbconn::LibPQ.Connection)

    # Look for a stay
    stay::Union{Missing,Stay} =
        StayCtrl.retrieveOneStay(patient,inDateTime,dbconn)

    # Create stay if missing
    if ismissing(stay)
        stay = StayCtrl.createStay(patient,
                                   unit,
                                   inDateTime,
                                   outDateTime,
                                   dbconn)
    else
        # Update the out-time if needed
        updateNeeded = false
        if (ismissing(stay.outDateTime) && !ismissing(outDateTime))
            stay.outDateTime = outDateTime
            updateNeeded = true
        end
        if (ismissing(stay.hospitalizationDate) && !ismissing(hospitalizationDate))
            stay.hospitalizationDate = hospitalizationDate
            updateNeeded = true
        end
        if updateNeeded
            PostgresORM.update_entity!(stay,dbconn)
        end
    end

    return stay

end

function StayCtrl.retrieveOneStay(patient::Patient,
                                  inDateTime::ZonedDateTime,
                                  dbconn::LibPQ.Connection)
        queryString = "
                SELECT s.* FROM stay s
                INNER JOIN patient p
                  ON s.patient_id = p.id
                WHERE p.id = \$1
                  AND s.in_date = \$2 -- targets the right partition
                  AND s.in_date_time = \$3"

        queryArgs = []
        push!(queryArgs, patient.id)
        push!(queryArgs, Dates.Date(inDateTime))
        push!(queryArgs, inDateTime)

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

function StayCtrl.retrieveOneStayContainingDate(patient::Patient,
                                                _date::Date,
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
                  AND s.in_date <= \$2 "

        queryArgs = []
        push!(queryArgs, patient.id)
        push!(queryArgs, _date)

        stays =
            PostgresORM.execute_query_and_handle_result(queryString,
                                                        Stay,
                                                        queryArgs,
                                                        false, # complex props
                                                        dbconn)
        # Put the stay closest to the target date first
        sort!(stays, by = x -> x.inDate - _date)

        if isempty(stays)
           return missing
        else
           return first(stays)
        end
end

function StayCtrl.createStay(patient::Patient,
                             unit::Unit,
                             inDateTime::ZonedDateTime,
                             outDateTime::Union{Missing,ZonedDateTime},
                             dbconn::LibPQ.Connection)

     stay = Stay(patient = patient,
                 unit = unit,
                 inDate = Dates.Date(inDateTime),
                 inDateTime = inDateTime,
                 outDateTime = outDateTime)
     TRAQUERUtil.createPartitionStayIfNotExist(stay,dbconn)
     PostgresORM.create_entity!(stay,dbconn)
     return stay

end

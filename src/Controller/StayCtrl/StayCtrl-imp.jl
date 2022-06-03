function StayCtrl.createStayIfNotExists(patient::Patient,
                                       unit::Unit,
                                       inTime::ZonedDateTime,
                                       outTime::Union{Missing,ZonedDateTime},
                                       hospitalizationInTime::Union{Missing,ZonedDateTime},
                                       hospitalizationOutTime::Union{Missing,ZonedDateTime},
                                       room::Union{Missing,String},
                                       dbconn::LibPQ.Connection)

    # Look for a stay
    stay::Union{Missing,Stay} =
        StayCtrl.retrieveOneStay(patient,inTime,dbconn)

    # Create stay if missing
    if ismissing(stay)
        stay = StayCtrl.createStay(patient,
                                   unit,
                                   inTime,
                                   outTime,
                                   hospitalizationInTime,
                                   hospitalizationOutTime,
                                   room,
                                   dbconn)
    else
        # Update the missing properties if the information is now available
        updateNeeded = false
        if (ismissing(stay.outTime) && !ismissing(outTime))
            stay.outTime = outTime
            updateNeeded = true
        end
        if (ismissing(stay.hospitalizationInTime) && !ismissing(hospitalizationInTime))
            stay.hospitalizationInTime = hospitalizationInTime
            updateNeeded = true
        end
        if (ismissing(stay.hospitalizationOutTime) && !ismissing(hospitalizationOutTime))
            stay.hospitalizationOutTime = hospitalizationOutTime
            updateNeeded = true
        end
        if (ismissing(stay.room) && !ismissing(room))
            stay.room = room
            updateNeeded = true
        end

        if updateNeeded
            PostgresORM.update_entity!(stay,dbconn)
        end

    end

    return stay

end

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

function StayCtrl.createStay(
    patient::Patient,
    unit::Unit,
    inTime::ZonedDateTime,
    outTime::Union{Missing,ZonedDateTime},
    hospitalizationInTime::Union{Missing,ZonedDateTime},
    hospitalizationOutTime::Union{Missing,ZonedDateTime},
    room::Union{Missing,String},
    dbconn::LibPQ.Connection
)

    stay = Stay(
        patient = patient,
        unit = unit,
        inDate = Dates.Date(inTime),
        inTime = inTime,
        outTime = outTime,
        hospitalizationInTime = hospitalizationInTime,
        hospitalizationOutTime = hospitalizationOutTime,
        room = room
    )
    TRAQUERUtil.createPartitionStayIfNotExist(stay,dbconn)
    PostgresORM.create_entity!(stay,dbconn)
    return stay

end

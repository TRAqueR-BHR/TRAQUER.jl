function StayCtrl.createStayIfNotExists(
    patient::Patient,
    unit::Unit,
    inTime::ZonedDateTime,
    outTime::Union{Missing,ZonedDateTime},
    hospitalizationInTime::Union{Missing,ZonedDateTime},
    hospitalizationOutTime::Union{Missing,ZonedDateTime},
    room::Union{Missing,String},
    dbconn::LibPQ.Connection
)

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

    # Update patient current hospitalization status
    StayCtrl.updateCurrentHospitalizationStatus(patient, dbconn)

    return stay

end

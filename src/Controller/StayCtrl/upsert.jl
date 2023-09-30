"""
    StayCtrl.upsert!(
        stay::Stay,
        dbconn::LibPQ.Connection
    )

Create/Update a stay
"""
function StayCtrl.upsert!(
    stay::Stay,
    dbconn::LibPQ.Connection
)

    # Set the inDate from the inTime
    stay.inDate = Dates.Date(astimezone(stay.inTime, getTimeZone()))

    # Look for a stay
    existingStay::Union{Missing,Stay} =
        StayCtrl.retrieveOneStay(stay.patient, stay.inTime, dbconn)

    # Create stay if missing
    if ismissing(existingStay)
        TRAQUERUtil.createPartitionStayIfNotExist(stay, dbconn)
        PostgresORM.create_entity!(stay,dbconn)
    else

        # Update the missing properties if the information is now available
        updateNeeded = false
        if (ismissing(existingStay.outTime) && !ismissing(stay.outTime))
            updateNeeded = true
            stay.id = existingStay.id
        end
        if (ismissing(existingStay.hospitalizationInTime) && !ismissing(stay.hospitalizationInTime))
            updateNeeded = true
            stay.id = existingStay.id
        end
        if (ismissing(existingStay.hospitalizationOutTime) && !ismissing(stay.hospitalizationOutTime))
            updateNeeded = true
            stay.id = existingStay.id
        end
        if (ismissing(existingStay.room) && !ismissing(stay.room))
            updateNeeded = true
            stay.id = existingStay.id
        end

        if updateNeeded
            PostgresORM.update_entity!(stay,dbconn)
        end

    end

    # Fix missing hospitalization status if any
    StayCtrl.fixMissingHospitalizationOutTime(stay.patient, dbconn)

    # Update patient current hospitalization status
    StayCtrl.updateCurrentHospitalizationStatus(stay.patient, dbconn)

    return stay

end

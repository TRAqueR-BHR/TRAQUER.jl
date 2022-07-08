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

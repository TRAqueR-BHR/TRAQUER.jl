function _TestUtils.createDummyStays(
    patient::Patient,
    units::Vector{Unit},
    dbconn::LibPQ.Connection;
    firstHospitalizationInTime::ZonedDateTime = now(TRAQUERUtil.getTimeZone()) - Day(30),
    numberOfStays::Integer = 10,
)::Vector{Stay}

    !isempty(units) || throw(ArgumentError("createDummyStays requires at least one unit"))
    numberOfStays >= 0 || throw(ArgumentError("numberOfStays must be non-negative"))

    stays = Stay[]

    firstHospitalizationOutTime = firstHospitalizationInTime + Day(10)
    secondHospitalizationInTime = firstHospitalizationInTime + Day(15)
    secondHospitalizationOutTime = secondHospitalizationInTime + Day(10)
    firstHospitalizationStayCount = cld(numberOfStays, 2)

    for i in 1:numberOfStays
        stayInTime = if i <= firstHospitalizationStayCount
            firstHospitalizationInTime + Day(2 * (i - 1))
        else
            secondHospitalizationInTime + Day(2 * (i - firstHospitalizationStayCount - 1))
        end
        stayOutTime = stayInTime + Day(2)
        hospitalizationInTime = i <= firstHospitalizationStayCount ? firstHospitalizationInTime : secondHospitalizationInTime
        hospitalizationOutTime = i <= firstHospitalizationStayCount ? firstHospitalizationOutTime : secondHospitalizationOutTime

        stay = Stay(
            patient = patient,
            unit = units[mod1(i, length(units))],
            inTime = stayInTime,
            outTime = stayOutTime,
            hospitalizationInTime = hospitalizationInTime,
            hospitalizationOutTime = hospitalizationOutTime,
            room = "TEST_ROOM_$(i)",
            patientDiedDuringStay = false,
        )

        StayCtrl.upsert!(stay, dbconn)
        push!(stays, stay)
    end

    return stays

end

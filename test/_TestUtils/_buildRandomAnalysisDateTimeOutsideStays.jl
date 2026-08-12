"""
    _TestUtils._buildRandomAnalysisDateTimeOutsideStays(
        patientBirthdate::Date,
    )::Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}

Generate random analysis request/result date-times outside known stay ranges.

The request time is generated between `patientBirthdate` and now. The result time may
be `missing`; when present, it is generated at or after the request time.
"""
function _TestUtils._buildRandomAnalysisDateTimeOutsideStays(
    patientBirthdate::Date,
)::Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}
    timezone = TRAQUERUtil.getTimeZone()
    currentTime = now(timezone)
    earliestTime = ZonedDateTime(DateTime(patientBirthdate), timezone)
    availableMinutes = max(
        0,
        Dates.value(DateTime(currentTime) - DateTime(earliestTime)) ÷ 60_000,
    )
    requestTime = earliestTime + Minute(rand(0:availableMinutes))

    resultTime = if rand() < 0.15
        missing
    else
        remainingMinutes = Dates.value(
            DateTime(currentTime) - DateTime(requestTime),
        ) ÷ 60_000
        requestTime + Minute(rand(0:remainingMinutes))
    end

    return requestTime => resultTime
end

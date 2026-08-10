"""
    _TestUtils.buildRandomAnalysisDateTime(
        staysDateTimes::AbstractVector{
            <:Pair{ZonedDateTime,<:Union{Missing,ZonedDateTime}},
        },
    )::Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}

Generate random analysis request/result date-times for a patient's unit stays.

# Arguments

- `staysDateTimes`: unit stay `in_time => out_time` pairs. Stay out-time may be
  `missing` for an ongoing stay.

# Returns

A `request_time => result_time` pair. The request time is generated inside one of the
provided stays. The result time may be `missing`; when present, it is generated at or
after the request time and before the selected stay out-time.
"""
function _TestUtils.buildRandomAnalysisDateTime(
    staysDateTimes::AbstractVector{<:Pair{ZonedDateTime,<:Union{Missing,ZonedDateTime}}},
)::Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}

    if isempty(staysDateTimes)
        throw(ArgumentError("staysDateTimes must not be empty"))
    end

    currentTime = now(TRAQUERUtil.getTimeZone())
    stayBounds = rand(staysDateTimes)
    stayInTime = first(stayBounds)
    stayOutTime = last(stayBounds)

    if !ismissing(stayOutTime) && stayOutTime < stayInTime
        throw(ArgumentError("stay out-time cannot be before in-time"))
    end

    # Missing stay out-time means the patient is still in the unit. Use the current
    # time only as the upper bound for generating plausible analysis timestamps.
    generationOutTime = if ismissing(stayOutTime)
        currentTime
    else
        stayOutTime
    end
    if generationOutTime < stayInTime
        throw(ArgumentError("ongoing stay in-time cannot be in the future"))
    end

    stayDurationMinutes = Dates.value(
        DateTime(generationOutTime) - DateTime(stayInTime),
    ) ÷ 60_000
    requestTime = stayInTime + Minute(rand(0:stayDurationMinutes))

    resultTime = if rand() < 0.15
        # Simulate an analysis request that has not received a result yet.
        missing
    else
        remainingMinutes = Dates.value(
            DateTime(generationOutTime) - DateTime(requestTime),
        ) ÷ 60_000
        requestTime + Minute(rand(0:remainingMinutes))
    end

    return requestTime => resultTime
end

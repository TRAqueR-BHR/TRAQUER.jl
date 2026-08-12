"""
    _TestUtils.buildRandomStaysDateTimes(
        hospitalizationBounds::Pair{ZonedDateTime,<:Union{Missing,ZonedDateTime}},
        nbStays::Integer,
    )::Vector{Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}}

Generate random unit stay date-time ranges within one hospitalization.

# Arguments

- `hospitalizationBounds`: `hospitalization_in_time => hospitalization_out_time` pair.
  The out time may be `missing` for an ongoing hospitalization.
- `nbStays`: number of unit stays to generate. Must be non-negative.

# Returns

A vector of `stay_in_time => stay_out_time` pairs ordered by admission time. The first
stay always starts at the hospitalization in-time. If the hospitalization out-time is
known, the last stay ends at that time. If the hospitalization is ongoing, the last
stay out-time is `missing`.
"""
function _TestUtils.buildRandomStaysDateTimes(
    hospitalizationBounds::Pair{ZonedDateTime,<:Union{Missing,ZonedDateTime}},
    nbStays::Integer,
)::Vector{Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}}

    if nbStays < 0
        throw(ArgumentError("nbStays must be non-negative"))
    end

    stays = Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}[]
    nbStays == 0 && return stays

    hospitalizationInTime = first(hospitalizationBounds)
    hospitalizationOutTime = last(hospitalizationBounds)
    if !ismissing(hospitalizationOutTime) && hospitalizationOutTime < hospitalizationInTime
        throw(ArgumentError("hospitalization out-time cannot be before in-time"))
    end

    # Missing hospitalization out-time means the patient is still hospitalized. Use the
    # current time only as a temporary upper bound to place preceding unit transfers.
    currentTime = now(TRAQUERUtil.getTimeZone())
    generationOutTime = if ismissing(hospitalizationOutTime)
        currentTime
    else
        hospitalizationOutTime
    end
    if generationOutTime < hospitalizationInTime
        throw(ArgumentError("hospitalization in-time cannot be in the future"))
    end

    availableMinutes = Dates.value(
        DateTime(generationOutTime) - DateTime(hospitalizationInTime),
    ) ÷ 60_000
    if availableMinutes < nbStays - 1
        throw(ArgumentError("hospitalization duration is too short for nbStays"))
    end

    # The first stay starts exactly with the hospitalization. Random offsets define
    # subsequent unit transfers while preserving chronological order.
    transferOffsets = Set{Int}()
    while length(transferOffsets) < nbStays - 1
        push!(transferOffsets, rand(1:availableMinutes))
    end

    stayOffsets = sort!([0; collect(transferOffsets)])
    stayInTimes = hospitalizationInTime .+ Minute.(stayOffsets)

    for (idx, stayInTime) in enumerate(stayInTimes)
        stayOutTime = if idx == nbStays
            hospitalizationOutTime
        else
            stayInTimes[idx + 1]
        end

        push!(stays, stayInTime => stayOutTime)
    end

    return stays
end

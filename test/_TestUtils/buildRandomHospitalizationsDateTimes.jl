"""
    _TestUtils.buildRandomHospitalizationsDateTimes(
        patientBirthdate::Date,
        nbHospitalizations::Integer,
    )::Vector{Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}}

Build random hospitalization date-time ranges for a patient born on `patientBirthdate`.

# Arguments

- `patientBirthdate`: patient birth date. Generated hospitalization admission times
  are never earlier than this date.
- `nbHospitalizations`: number of hospitalization ranges to generate. Must be
  non-negative.

# Returns

A vector of `hospitalization_in_time => hospitalization_out_time` pairs ordered by
admission time. `hospitalization_out_time` may be `missing` to represent an ongoing
hospitalization.

Generated hospitalization ranges do not overlap: each discharge time is capped before
the next generated admission time.
"""
function _TestUtils.buildRandomHospitalizationsDateTimes(
    patientBirthdate::Date,
    nbHospitalizations::Integer,
)::Vector{Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}}

    if nbHospitalizations < 0
        throw(ArgumentError("nbHospitalizations must be non-negative"))
    end

    timezone = TRAQUERUtil.getTimeZone()
    currentTime = now(timezone)
    if patientBirthdate > Date(currentTime)
        throw(ArgumentError("patientBirthdate cannot be in the future"))
    end

    hospitalizations = Pair{ZonedDateTime,Union{Missing,ZonedDateTime}}[]
    nbHospitalizations == 0 && return hospitalizations

    # Use the patient's birth date as the lower bound so generated admissions are
    # always plausible for that patient.
    earliestTime = ZonedDateTime(DateTime(patientBirthdate), timezone)
    availableMinutes = max(
        1,
        Dates.value(DateTime(currentTime) - DateTime(earliestTime)) ÷ 60_000,
    )

    hospitalizationInTimes = ZonedDateTime[]
    for i in 1:nbHospitalizations
        # Split the full time span into buckets before sampling. This keeps
        # generated admissions spread over the patient's life instead of clustered.
        rangeStart = ((i - 1) * availableMinutes) ÷ nbHospitalizations
        rangeStop = (i * availableMinutes) ÷ nbHospitalizations
        offsetMinutes = rand(rangeStart:rangeStop)
        hospitalizationInTime = min(earliestTime + Minute(offsetMinutes), currentTime)
        push!(hospitalizationInTimes, hospitalizationInTime)
    end

    sort!(hospitalizationInTimes)

    for (idx, hospitalizationInTime) in enumerate(hospitalizationInTimes)
        # Cap each discharge before the next admission to avoid overlapping
        # hospitalizations for the same generated patient.
        maxOutTime = if idx == nbHospitalizations
            currentTime
        else
            hospitalizationInTimes[idx + 1] - Minute(1)
        end

        hospitalizationOutTime = if idx == nbHospitalizations && rand() < 0.15
            # Simulate a patient who is still hospitalized in a small number of cases.
            missing
        elseif maxOutTime <= hospitalizationInTime
            missing
        else
            min(hospitalizationInTime + Day(rand(1:21)), maxOutTime)
        end

        push!(hospitalizations, hospitalizationInTime => hospitalizationOutTime)
    end

    return hospitalizations
end

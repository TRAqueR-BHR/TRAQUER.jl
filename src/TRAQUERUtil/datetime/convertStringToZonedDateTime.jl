function TRAQUERUtil.convertStringToZonedDateTime(str::AbstractString)

    # Eg. "2021-12-21T23:39:40.000Z", "2021-12-21T23:39:40.000+01:00"
    # => remove the milliseconds (the '[0-9]3' in the regexp)
    dateMatch = match(
        r"^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}).[0-9]{3}(.*)",
        str)
    if !isnothing(dateMatch)
        _dateTime  = dateMatch.captures[1]
        _tz = dateMatch.captures[2]
        formatString = "yyyy-mm-ddTHH:MM:SSzzz"
        return ZonedDateTime(string(_dateTime,_tz), formatString)
    end

    # yyyy-mm-dd ....
    dateMatch = match(r"^([0-9]{4}-[0-9]{2}-[0-9]{2})", str)
    if !isnothing(dateMatch)
        formatString = "yyyy-mm-ddTHH:MM:SSzzz"
        return ZonedDateTime(str, formatString)
    end

    # dd/mm/yyyy....
    dateMatch = match(r"^([0-9]{2}/[0-9]{2}/[0-9]{4})", str)
    if !isnothing(dateMatch)
        formatString = "dd/mm/yyyy HH:MM:SS"
        return ZonedDateTime(TRAQUERUtil.convertStringToDateTime(str),
                             TRAQUERUtil.getTimeZone())
    end

end

function TRAQUERUtil.convertStringToZonedDateTime(
    dateStr::AbstractString,
    timeStr::AbstractString,
    _tz::VariableTimeZone
)

    dateDate = Date(dateStr,DateFormat("d/m/y"))
    timeTime = begin

        timeTemp = missing

        if length(timeStr) == 1
            timeTemp = Time(timeStr, DateFormat("M"))
        end

        if length(timeStr) == 2
            timeTemp = Time(timeStr, DateFormat("MM"))
        end


        if length(timeStr) == 3
            timeTemp = Time(timeStr, DateFormat("HMM"))
        end

        if length(timeStr) == 4
            timeTemp = Time(timeStr, DateFormat("HHMM"))
        end

        if length(timeStr) == 5
            timeTemp = Time(timeStr, DateFormat("HH:MM"))
        end

        if length(timeStr) == 8
            timeTemp = Time(timeStr, DateFormat("HH:MM:SS"))
        end

        timeTemp

    end

    dateTimes = DateTime(dateDate, timeTime)

    inDateTest =  TimeZones.first_valid(dateTimes,_tz)

    return  inDateTest
end

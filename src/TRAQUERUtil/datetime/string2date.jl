function TRAQUERUtil.string2date(str::AbstractString)
    dateMatch = match(r"^([0-9]{4}-[0-9]{2}-[0-9]{2})",str)
    Date(dateMatch.match)
end

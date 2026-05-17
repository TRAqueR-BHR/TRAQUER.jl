function TRAQUERUtil.createHospitalZonedDateTime(dateTime::DateTime)
    return ZonedDateTime(dateTime, TRAQUERUtil.getTimeZone())
end

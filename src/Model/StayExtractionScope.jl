"""
Registry of scopes of stay data that are requested from the source system (the hospital information system) at a given time.
"""
mutable struct StayExtractionScope <: IStayExtractionScope 

  stayMonitoringScope::Union{Missing,Model.IStayMonitoringScope}
  id::Union{Missing,String}

  # End time of the period of interest (to be compared with stay.in_time not out_time). It
  # usually is more restrictive than stay_monitoring_scope.period_oi_end_time
  periodOiEndTime::Union{Missing,ZonedDateTime}

  # Start time of the period of interest (to be compared with stay.in_time). It usually is more
  # restrictive than stay_monitoring_scope.period_oi_start_time
  periodOiStartTime::Union{Missing,ZonedDateTime}

  requestTime::Union{Missing,ZonedDateTime} # Time when this extraction scope was requested

  StayExtractionScope(args::NamedTuple) = StayExtractionScope(;args...)
  StayExtractionScope(;
    stayMonitoringScope = missing,
    id = missing,
    periodOiEndTime = missing,
    periodOiStartTime = missing,
    requestTime = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,)
    x.stayMonitoringScope = stayMonitoringScope
    x.id = id
    x.periodOiEndTime = periodOiEndTime
    x.periodOiStartTime = periodOiStartTime
    x.requestTime = requestTime
    return x
  end

end 
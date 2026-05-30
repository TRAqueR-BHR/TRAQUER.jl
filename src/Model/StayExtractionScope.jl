"""
Registry of scopes of stay data that are requested from the source system (the hospital information system) at a given time.
"""
mutable struct StayExtractionScope <: IStayExtractionScope 

  stayMonitoringScope::Union{Missing,Model.IStayMonitoringScope}
  id::Union{Missing,String}
  requestTime::Union{Missing,ZonedDateTime} # Time when this extraction scope was requested

  StayExtractionScope(args::NamedTuple) = StayExtractionScope(;args...)
  StayExtractionScope(;
    stayMonitoringScope = missing,
    id = missing,
    requestTime = missing,
  ) = begin
    x = new(missing,missing,missing,)
    x.stayMonitoringScope = stayMonitoringScope
    x.id = id
    x.requestTime = requestTime
    return x
  end

end 
"""
Registry of scopes of stay data that are requested from the source system (the hospital information system) at a given time.
"""
mutable struct StayExtractionScopeDTO <: IStayExtractionScopeDTO

  id::Union{Missing,String} # Copy of StayExtractionScope.id

  # Time when this extraction scope was requested
  # NOTE: This is a copy of StayExtractionScope.requestTime
  requestTime::Union{Missing,ZonedDateTime}

  # Start time of the period of interest (to be compared with stay.in_time)
  # NOTE: This is a copy of StayMonitoringScope.periodOiStartTime
  periodOiStartTime::Union{Missing,ZonedDateTime}

  # End time of the period of interest (to be compared with stay.in_time not out_time)
  # NOTE: This is a copy of StayMonitoringScope.periodOiEndTime
  periodOiEndTime::Union{Missing,ZonedDateTime}

  # Vector of unit codes
  # NOTE: Derived from StayMonitoringScope.unitIds
  unitCodeNames::Union{Missing,Vector{String}}

  # Vector of patient references (decrypted)
  # NOTE: Derived from StayMonitoringScope.patientIds
  patientRefs::Union{Missing,Vector{String}}

  # Justification of why this scope of stay data is monitored. This is just a hint for the
  # admins or the auditors.
  justification::Union{Missing,String}

  StayExtractionScopeDTO(args::NamedTuple) = StayExtractionScopeDTO(;args...)
  StayExtractionScopeDTO(;
    id = missing,
    requestTime = missing,
    periodOiStartTime = missing,
    periodOiEndTime = missing,
    unitCodeNames = missing,
    patientRefs = missing,
    justification = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.requestTime = requestTime
    x.periodOiStartTime = periodOiStartTime
    x.periodOiEndTime = periodOiEndTime
    x.unitCodeNames = unitCodeNames
    x.patientRefs = patientRefs
    x.justification = justification
    return x
  end

end

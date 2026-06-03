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

  # Unit code name, when the monitoring scope targets a unit
  # NOTE: Derived from StayMonitoringScope.monitoredUnit
  monitoredUnitCodeName::Union{Missing,String}

  # Patient reference (decrypted), when the monitoring scope targets a patient
  # NOTE: Derived from StayMonitoringScope.monitoredPatient
  monitoredPatientRef::Union{Missing,String}

  StayExtractionScopeDTO(args::NamedTuple) = StayExtractionScopeDTO(;args...)
  StayExtractionScopeDTO(;
    id = missing,
    requestTime = missing,
    periodOiStartTime = missing,
    periodOiEndTime = missing,
    monitoredUnitCodeName = missing,
    monitoredPatientRef = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.requestTime = requestTime
    x.periodOiStartTime = periodOiStartTime
    x.periodOiEndTime = periodOiEndTime
    x.monitoredUnitCodeName = monitoredUnitCodeName
    x.monitoredPatientRef = monitoredPatientRef
    return x
  end

end

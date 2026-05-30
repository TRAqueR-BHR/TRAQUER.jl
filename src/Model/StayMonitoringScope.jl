"""
Registry of scopes of stay data that are monitored over time.
"""
mutable struct StayMonitoringScope <: IStayMonitoringScope 

  id::Union{Missing,String}

  # End time of the period of interest (to be compared with stay.in_time not out_time)
  periodOiEndTime::Union{Missing,ZonedDateTime}

  # Condition under which this scope of stay data is no longer monitored and therefore gets
  # deactivated. Also see deactivation_time
  deactivationCondition::Union{Missing,String}

  # Start time of the period of interest (to be compared with stay.in_time)
  periodOiStartTime::Union{Missing,ZonedDateTime}

  unitIds::Union{Missing,String} # Comma-separated list of unit IDs of interest

  # Time when this scope of stay data was activated
  activationTime::Union{Missing,ZonedDateTime}

  patientIds::Union{Missing,String} # Comma-separated list of patient IDs of interest

  # Time when this scope of stay data was deactivated (also see deactivation_condition)
  deactivationTime::Union{Missing,ZonedDateTime}

  # Justification of why this scope of stay data is monitored. This is just a hint for the
  # admins or the auditors.
  justification::Union{Missing,String}

  stayExtractionScopes::Union{Missing,Vector{Model.IStayExtractionScope}}

  StayMonitoringScope(args::NamedTuple) = StayMonitoringScope(;args...)
  StayMonitoringScope(;
    id = missing,
    periodOiEndTime = missing,
    deactivationCondition = missing,
    periodOiStartTime = missing,
    unitIds = missing,
    activationTime = missing,
    patientIds = missing,
    deactivationTime = missing,
    justification = missing,
    stayExtractionScopes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.periodOiEndTime = periodOiEndTime
    x.deactivationCondition = deactivationCondition
    x.periodOiStartTime = periodOiStartTime
    x.unitIds = unitIds
    x.activationTime = activationTime
    x.patientIds = patientIds
    x.deactivationTime = deactivationTime
    x.justification = justification
    x.stayExtractionScopes = stayExtractionScopes
    return x
  end

end 
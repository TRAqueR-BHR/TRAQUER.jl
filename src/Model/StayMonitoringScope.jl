"""
Registry of scopes of stay data that are monitored over time.
"""
mutable struct StayMonitoringScope <: IStayMonitoringScope 

  monitoredUnit::Union{Missing,Model.IUnit}
  monitoredPatient::Union{Missing,Model.IPatient}
  justifyingOutbreak::Union{Missing,Model.IOutbreak}
  justifyingInfectiousStatus::Union{Missing,Model.IInfectiousStatus}
  id::Union{Missing,String}

  # End time of the period of interest (to be compared with stay.in_time not out_time)
  periodOiEndTime::Union{Missing,ZonedDateTime}

  # Start time of the period of interest (to be compared with stay.in_time)
  periodOiStartTime::Union{Missing,ZonedDateTime}

  # Time when this scope of stay data was activated
  activationTime::Union{Missing,ZonedDateTime}

  # Time when this scope of stay data was deactivated (also see deactivation_condition)
  deactivationTime::Union{Missing,ZonedDateTime}

  # Additional information, if necessary, explaining why this scope of stay data is monitored.
  # This is just a hint for the admins or the auditors.
  justificationAdditionalInfo::Union{Missing,String}

  stayExtractionScopes::Union{Missing,Vector{Model.IStayExtractionScope}}

  StayMonitoringScope(args::NamedTuple) = StayMonitoringScope(;args...)
  StayMonitoringScope(;
    monitoredUnit = missing,
    monitoredPatient = missing,
    justifyingOutbreak = missing,
    justifyingInfectiousStatus = missing,
    id = missing,
    periodOiEndTime = missing,
    periodOiStartTime = missing,
    activationTime = missing,
    deactivationTime = missing,
    justificationAdditionalInfo = missing,
    stayExtractionScopes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.monitoredUnit = monitoredUnit
    x.monitoredPatient = monitoredPatient
    x.justifyingOutbreak = justifyingOutbreak
    x.justifyingInfectiousStatus = justifyingInfectiousStatus
    x.id = id
    x.periodOiEndTime = periodOiEndTime
    x.periodOiStartTime = periodOiStartTime
    x.activationTime = activationTime
    x.deactivationTime = deactivationTime
    x.justificationAdditionalInfo = justificationAdditionalInfo
    x.stayExtractionScopes = stayExtractionScopes
    return x
  end

end 
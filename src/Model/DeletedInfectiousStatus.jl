mutable struct DeletedInfectiousStatus <: IDeletedInfectiousStatus 

  patient::Union{Missing,Model.IPatient}
  id::Union{Missing,String}
  infectiousStatus::Union{Missing,InfectiousStatusType.INFECTIOUS_STATUS_TYPE}
  refTime::Union{Missing,ZonedDateTime}
  infectiousAgent::Union{Missing,InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}

  DeletedInfectiousStatus(args::NamedTuple) = DeletedInfectiousStatus(;args...)
  DeletedInfectiousStatus(;
    patient = missing,
    id = missing,
    infectiousStatus = missing,
    refTime = missing,
    infectiousAgent = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,)
    x.patient = patient
    x.id = id
    x.infectiousStatus = infectiousStatus
    x.refTime = refTime
    x.infectiousAgent = infectiousAgent
    return x
  end

end 
mutable struct InfectiousStatus <: IInfectiousStatus 

  patient::Union{Missing,Model.IPatient}
  id::Union{Missing,String}
  isCurrent::Union{Missing,Bool}
  infectiousStatus::Union{Missing,InfectiousStatusType.INFECTIOUS_STATUS_TYPE}
  isConfirmed::Union{Missing,Bool}
  refTime::Union{Missing,ZonedDateTime}
  infectiousAgent::Union{Missing,InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}
  outbreakInfectiousStatusAssoes::Union{Missing,Vector{Model.IOutbreakInfectiousStatusAsso}}

  InfectiousStatus(args::NamedTuple) = InfectiousStatus(;args...)
  InfectiousStatus(;
    patient = missing,
    id = missing,
    isCurrent = missing,
    infectiousStatus = missing,
    isConfirmed = missing,
    refTime = missing,
    infectiousAgent = missing,
    outbreakInfectiousStatusAssoes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.id = id
    x.isCurrent = isCurrent
    x.infectiousStatus = infectiousStatus
    x.isConfirmed = isConfirmed
    x.refTime = refTime
    x.infectiousAgent = infectiousAgent
    x.outbreakInfectiousStatusAssoes = outbreakInfectiousStatusAssoes
    return x
  end

end 
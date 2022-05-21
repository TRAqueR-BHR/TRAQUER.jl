mutable struct InfectiousStatus <: IInfectiousStatus 

  patient::Union{Missing,Model.IPatient}
  id::Union{Missing,String}
  creationTime::Union{Missing,ZonedDateTime}
  infectiousStatusType::Union{Missing,InfectiousStatusType.INFECTIOUS_STATUS_TYPE}
  refTime::Union{Missing,ZonedDateTime}
  infectiousAgent::Union{Missing,InfectiousAgentCodeName.INFECTIOUS_AGENT_CODE_NAME}
  outbreakInfectiousStatusAssoes::Union{Missing,Vector{Model.IOutbreakInfectiousStatusAsso}}

  InfectiousStatus(args::NamedTuple) = InfectiousStatus(;args...)
  InfectiousStatus(;
    patient = missing,
    id = missing,
    creationTime = missing,
    infectiousStatusType = missing,
    refTime = missing,
    infectiousAgent = missing,
    outbreakInfectiousStatusAssoes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.id = id
    x.creationTime = creationTime
    x.infectiousStatusType = infectiousStatusType
    x.refTime = refTime
    x.infectiousAgent = infectiousAgent
    x.outbreakInfectiousStatusAssoes = outbreakInfectiousStatusAssoes
    return x
  end

end 
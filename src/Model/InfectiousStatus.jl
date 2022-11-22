mutable struct InfectiousStatus <: IInfectiousStatus 

  patient::Union{Missing,Model.IPatient}
  id::Union{Missing,String}
  isCurrent::Union{Missing,Bool}
  infectiousStatus::Union{Missing,InfectiousStatusType.INFECTIOUS_STATUS_TYPE}
  analysisRequestStatus::Union{Missing,AnalysisRequestStatusType.ANALYSIS_REQUEST_STATUS_TYPE}
  isConfirmed::Union{Missing,Bool}
  refTime::Union{Missing,ZonedDateTime}
  infectiousAgent::Union{Missing,InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}
  eventRequiringAttentions::Union{Missing,Vector{Model.IEventRequiringAttention}}
  outbreakInfectiousStatusAssoes::Union{Missing,Vector{Model.IOutbreakInfectiousStatusAsso}}

  InfectiousStatus(args::NamedTuple) = InfectiousStatus(;args...)
  InfectiousStatus(;
    patient = missing,
    id = missing,
    isCurrent = missing,
    infectiousStatus = missing,
    analysisRequestStatus = missing,
    isConfirmed = missing,
    refTime = missing,
    infectiousAgent = missing,
    eventRequiringAttentions = missing,
    outbreakInfectiousStatusAssoes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.id = id
    x.isCurrent = isCurrent
    x.infectiousStatus = infectiousStatus
    x.analysisRequestStatus = analysisRequestStatus
    x.isConfirmed = isConfirmed
    x.refTime = refTime
    x.infectiousAgent = infectiousAgent
    x.eventRequiringAttentions = eventRequiringAttentions
    x.outbreakInfectiousStatusAssoes = outbreakInfectiousStatusAssoes
    return x
  end

end 
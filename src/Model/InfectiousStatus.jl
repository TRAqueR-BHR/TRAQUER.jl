mutable struct InfectiousStatus <: IInfectiousStatus 

  patient::Union{Missing,Model.IPatient}
  contactExposure::Union{Missing,Model.IContactExposure}
  id::Union{Missing,String}
  isConfirmed::Union{Missing,Bool}
  refTime::Union{Missing,ZonedDateTime}
  infectiousAgent::Union{Missing,InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}
  analysisRequestStatus::Union{Missing,AnalysisRequestStatusType.ANALYSIS_REQUEST_STATUS_TYPE}
  updatedRefTime::Union{Missing,ZonedDateTime}
  isCancelled::Union{Missing,Bool}
  isCurrent::Union{Missing,Bool}
  infectiousStatus::Union{Missing,InfectiousStatusType.INFECTIOUS_STATUS_TYPE}
  outbreakInfectiousStatusAssoes::Union{Missing,Vector{Model.IOutbreakInfectiousStatusAsso}}
  eventRequiringAttentions::Union{Missing,Vector{Model.IEventRequiringAttention}}

  InfectiousStatus(args::NamedTuple) = InfectiousStatus(;args...)
  InfectiousStatus(;
    patient = missing,
    contactExposure = missing,
    id = missing,
    isConfirmed = missing,
    refTime = missing,
    infectiousAgent = missing,
    analysisRequestStatus = missing,
    updatedRefTime = missing,
    isCancelled = missing,
    isCurrent = missing,
    infectiousStatus = missing,
    outbreakInfectiousStatusAssoes = missing,
    eventRequiringAttentions = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.contactExposure = contactExposure
    x.id = id
    x.isConfirmed = isConfirmed
    x.refTime = refTime
    x.infectiousAgent = infectiousAgent
    x.analysisRequestStatus = analysisRequestStatus
    x.updatedRefTime = updatedRefTime
    x.isCancelled = isCancelled
    x.isCurrent = isCurrent
    x.infectiousStatus = infectiousStatus
    x.outbreakInfectiousStatusAssoes = outbreakInfectiousStatusAssoes
    x.eventRequiringAttentions = eventRequiringAttentions
    return x
  end

end 
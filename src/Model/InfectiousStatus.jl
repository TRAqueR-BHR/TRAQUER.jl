mutable struct InfectiousStatus <: IInfectiousStatus 

  patient::Union{Missing,Model.IPatient}
  contactExposure::Union{Missing,Model.IContactExposure}
  id::Union{Missing,String}
  isCurrent::Union{Missing,Bool}
  updatedRefTime::Union{Missing,ZonedDateTime}
  infectiousStatus::Union{Missing,InfectiousStatusType.INFECTIOUS_STATUS_TYPE}
  analysisRequestStatus::Union{Missing,AnalysisRequestStatusType.ANALYSIS_REQUEST_STATUS_TYPE}
  isConfirmed::Union{Missing,Bool}
  refTime::Union{Missing,ZonedDateTime}
  infectiousAgent::Union{Missing,InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}
  outbreakInfectiousStatusAssoes::Union{Missing,Vector{Model.IOutbreakInfectiousStatusAsso}}
  eventRequiringAttentions::Union{Missing,Vector{Model.IEventRequiringAttention}}

  InfectiousStatus(args::NamedTuple) = InfectiousStatus(;args...)
  InfectiousStatus(;
    patient = missing,
    contactExposure = missing,
    id = missing,
    isCurrent = missing,
    updatedRefTime = missing,
    infectiousStatus = missing,
    analysisRequestStatus = missing,
    isConfirmed = missing,
    refTime = missing,
    infectiousAgent = missing,
    outbreakInfectiousStatusAssoes = missing,
    eventRequiringAttentions = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.patient = patient
    x.contactExposure = contactExposure
    x.id = id
    x.isCurrent = isCurrent
    x.updatedRefTime = updatedRefTime
    x.infectiousStatus = infectiousStatus
    x.analysisRequestStatus = analysisRequestStatus
    x.isConfirmed = isConfirmed
    x.refTime = refTime
    x.infectiousAgent = infectiousAgent
    x.outbreakInfectiousStatusAssoes = outbreakInfectiousStatusAssoes
    x.eventRequiringAttentions = eventRequiringAttentions
    return x
  end

end 
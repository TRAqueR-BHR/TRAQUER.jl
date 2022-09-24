mutable struct EventRequiringAttention <: IEventRequiringAttention 

  responseUser::Union{Missing,Model.IAppuser}
  infectiousStatus::Union{Missing,Model.IInfectiousStatus}
  id::Union{Missing,String}
  responseTime::Union{Missing,ZonedDateTime}
  responseComment::Union{Missing,String}
  isPending::Union{Missing,Bool}
  eventType::Union{Missing,EventRequiringAttentionType.EVENT_REQUIRING_ATTENTION_TYPE}
  refTime::Union{Missing,ZonedDateTime}
  responsesTypes::Union{Missing,Vector{ResponseType.RESPONSE_TYPE}}

  EventRequiringAttention(args::NamedTuple) = EventRequiringAttention(;args...)
  EventRequiringAttention(;
    responseUser = missing,
    infectiousStatus = missing,
    id = missing,
    responseTime = missing,
    responseComment = missing,
    isPending = missing,
    eventType = missing,
    refTime = missing,
    responsesTypes = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.responseUser = responseUser
    x.infectiousStatus = infectiousStatus
    x.id = id
    x.responseTime = responseTime
    x.responseComment = responseComment
    x.isPending = isPending
    x.eventType = eventType
    x.refTime = refTime
    x.responsesTypes = responsesTypes
    return x
  end

end 
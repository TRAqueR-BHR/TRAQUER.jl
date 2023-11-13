mutable struct EventRequiringAttention <: IEventRequiringAttention 

  responseUser::Union{Missing,Model.IAppuser}
  infectiousStatus::Union{Missing,Model.IInfectiousStatus}
  id::Union{Missing,String}
  refTime::Union{Missing,ZonedDateTime}
  responsesTypes::Union{Missing,Vector{ResponseType.RESPONSE_TYPE}}
  isPending::Union{Missing,Bool}
  eventType::Union{Missing,EventRequiringAttentionType.EVENT_REQUIRING_ATTENTION_TYPE}
  isNotificationSent::Union{Missing,Bool}
  responseTime::Union{Missing,ZonedDateTime}
  responseComment::Union{Missing,String}
  creationTime::Union{Missing,ZonedDateTime}

  EventRequiringAttention(args::NamedTuple) = EventRequiringAttention(;args...)
  EventRequiringAttention(;
    responseUser = missing,
    infectiousStatus = missing,
    id = missing,
    refTime = missing,
    responsesTypes = missing,
    isPending = missing,
    eventType = missing,
    isNotificationSent = missing,
    responseTime = missing,
    responseComment = missing,
    creationTime = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.responseUser = responseUser
    x.infectiousStatus = infectiousStatus
    x.id = id
    x.refTime = refTime
    x.responsesTypes = responsesTypes
    x.isPending = isPending
    x.eventType = eventType
    x.isNotificationSent = isNotificationSent
    x.responseTime = responseTime
    x.responseComment = responseComment
    x.creationTime = creationTime
    return x
  end

end 
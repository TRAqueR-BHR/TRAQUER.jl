mutable struct EventRequiringAttention <: IEventRequiringAttention 

  responseUser::Union{Missing,Model.IAppuser}
  infectiousStatus::Union{Missing,Model.IInfectiousStatus}
  id::Union{Missing,String}
  response::Union{Missing,UserResponseType.USER_RESPONSE_TYPE}
  responseTime::Union{Missing,ZonedDateTime}
  responseComment::Union{Missing,String}
  isPending::Union{Missing,Bool}
  eventType::Union{Missing,EventRequiringAttentionType.EVENT_REQUIRING_ATTENTION_TYPE}
  refTime::Union{Missing,ZonedDateTime}

  EventRequiringAttention(args::NamedTuple) = EventRequiringAttention(;args...)
  EventRequiringAttention(;
    responseUser = missing,
    infectiousStatus = missing,
    id = missing,
    response = missing,
    responseTime = missing,
    responseComment = missing,
    isPending = missing,
    eventType = missing,
    refTime = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,missing,missing,)
    x.responseUser = responseUser
    x.infectiousStatus = infectiousStatus
    x.id = id
    x.response = response
    x.responseTime = responseTime
    x.responseComment = responseComment
    x.isPending = isPending
    x.eventType = eventType
    x.refTime = refTime
    return x
  end

end 
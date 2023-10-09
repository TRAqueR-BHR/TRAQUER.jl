mutable struct TaskWaitingForUserExecution <: ITaskWaitingForUserExecution 

  id::Union{Missing,String}
  startTime::Union{Missing,ZonedDateTime}
  name::Union{Missing,String}
  errorMsg::Union{Missing,String}
  creationTime::Union{Missing,ZonedDateTime}
  success::Union{Missing,Bool}
  endOrErrorTime::Union{Missing,ZonedDateTime}

  TaskWaitingForUserExecution(args::NamedTuple) = TaskWaitingForUserExecution(;args...)
  TaskWaitingForUserExecution(;
    id = missing,
    startTime = missing,
    name = missing,
    errorMsg = missing,
    creationTime = missing,
    success = missing,
    endOrErrorTime = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.startTime = startTime
    x.name = name
    x.errorMsg = errorMsg
    x.creationTime = creationTime
    x.success = success
    x.endOrErrorTime = endOrErrorTime
    return x
  end

end 
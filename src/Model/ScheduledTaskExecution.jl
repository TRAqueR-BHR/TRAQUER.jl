mutable struct ScheduledTaskExecution <: IScheduledTaskExecution 

  id::Union{Missing,String}
  startTime::Union{Missing,ZonedDateTime}
  name::Union{Missing,String}

  ScheduledTaskExecution(args::NamedTuple) = ScheduledTaskExecution(;args...)
  ScheduledTaskExecution(;
    id = missing,
    startTime = missing,
    name = missing,
  ) = begin
    x = new(missing,missing,missing,)
    x.id = id
    x.startTime = startTime
    x.name = name
    return x
  end

end 
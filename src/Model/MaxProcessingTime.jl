mutable struct MaxProcessingTime <: IMaxProcessingTime 

  id::Union{Missing,String}
  maxTime::Union{Missing,ZonedDateTime}

  MaxProcessingTime(args::NamedTuple) = MaxProcessingTime(;args...)
  MaxProcessingTime(;
    id = missing,
    maxTime = missing,
  ) = begin
    x = new(missing,missing,)
    x.id = id
    x.maxTime = maxTime
    return x
  end

end 
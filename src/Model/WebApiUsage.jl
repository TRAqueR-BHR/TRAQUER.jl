mutable struct WebApiUsage <: IWebApiUsage 

  user::Union{Missing,Model.IAppuser}
  id::Union{Missing,String}
  inTime::Union{Missing,ZonedDateTime}
  outTime::Union{Missing,ZonedDateTime}
  apiUrl::Union{Missing,String}

  WebApiUsage(args::NamedTuple) = WebApiUsage(;args...)
  WebApiUsage(;
    user = missing,
    id = missing,
    inTime = missing,
    outTime = missing,
    apiUrl = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,)
    x.user = user
    x.id = id
    x.inTime = inTime
    x.outTime = outTime
    x.apiUrl = apiUrl
    return x
  end

end 
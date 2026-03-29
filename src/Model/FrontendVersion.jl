"""
A table that gives the expected version of the frontend
"""
mutable struct FrontendVersion <: IFrontendVersion 

  id::Union{Missing,String}
  name::Union{Missing,String} # efwf w 
  forceReloadIfDifferentVersion::Union{Missing,Bool}

  FrontendVersion(args::NamedTuple) = FrontendVersion(;args...)
  FrontendVersion(;
    id = missing,
    name = missing,
    forceReloadIfDifferentVersion = missing,
  ) = begin
    x = new(missing,missing,missing,)
    x.id = id
    x.name = name
    x.forceReloadIfDifferentVersion = forceReloadIfDifferentVersion
    return x
  end

end 
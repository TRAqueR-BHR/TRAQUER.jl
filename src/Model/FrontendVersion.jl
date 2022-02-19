mutable struct FrontendVersion <: IFrontendVersion 

  id::Union{Missing,String}
  name::Union{Missing,String}
  forceReloadIfDifferentVersion::Union{Missing,Bool}

  FrontendVersion(args::NamedTuple) = FrontendVersion(;args...)
  FrontendVersion(;
    id = missing,
    name = missing,
    forceReloadIfDifferentVersion = missing,
  ) = (
    x = new(missing,missing,missing,);
    x.id = id;
    x.name = name;
    x.forceReloadIfDifferentVersion = forceReloadIfDifferentVersion;
    return x
  )

end 
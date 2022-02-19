mutable struct Unit <: IUnit 

  id::Union{Missing,String}
  name::Union{Missing,String}
  codeName::Union{Missing,String}
  stays::Union{Missing,Vector{Model.IStay}}
  contactExposures::Union{Missing,Vector{Model.IContactExposure}}

  Unit(args::NamedTuple) = Unit(;args...)
  Unit(;
    id = missing,
    name = missing,
    codeName = missing,
    stays = missing,
    contactExposures = missing,
  ) = (
    x = new(missing,missing,missing,missing,missing,);
    x.id = id;
    x.name = name;
    x.codeName = codeName;
    x.stays = stays;
    x.contactExposures = contactExposures;
    return x
  )

end 
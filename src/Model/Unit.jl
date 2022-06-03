mutable struct Unit <: IUnit 

  id::Union{Missing,String}
  name::Union{Missing,String}
  codeName::Union{Missing,String}
  outbreakConfigUnitAssoes::Union{Missing,Vector{Model.IOutbreakConfigUnitAsso}}
  stays::Union{Missing,Vector{Model.IStay}}
  contactExposures::Union{Missing,Vector{Model.IContactExposure}}

  Unit(args::NamedTuple) = Unit(;args...)
  Unit(;
    id = missing,
    name = missing,
    codeName = missing,
    outbreakConfigUnitAssoes = missing,
    stays = missing,
    contactExposures = missing,
  ) = begin
    x = new(missing,missing,missing,missing,missing,missing,)
    x.id = id
    x.name = name
    x.codeName = codeName
    x.outbreakConfigUnitAssoes = outbreakConfigUnitAssoes
    x.stays = stays
    x.contactExposures = contactExposures
    return x
  end

end 
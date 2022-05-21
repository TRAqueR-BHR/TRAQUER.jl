mutable struct InfectionType <: IInfectionType 

  id::Union{Missing,String}
  nameFr::Union{Missing,String}
  codeName::Union{Missing,String}
  nameEn::Union{Missing,String}

  InfectionType(args::NamedTuple) = InfectionType(;args...)
  InfectionType(;
    id = missing,
    nameFr = missing,
    codeName = missing,
    nameEn = missing,
  ) = begin
    x = new(missing,missing,missing,missing,)
    x.id = id
    x.nameFr = nameFr
    x.codeName = codeName
    x.nameEn = nameEn
    return x
  end

end 
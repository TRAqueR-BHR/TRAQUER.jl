mutable struct FctUnit <: IFctUnit 

  id::Union{Missing,String}
  name::Union{Missing,String}
  codeName::Union{Missing,String}
  fctUnitStaies::Union{Missing,Vector{Model.IFctUnitStay}}

  FctUnit(args::NamedTuple) = FctUnit(;args...)
  FctUnit(;
    id = missing,
    name = missing,
    codeName = missing,
    fctUnitStaies = missing,
  ) = (
    x = new(missing,missing,missing,missing,);
    x.id = id;
    x.name = name;
    x.codeName = codeName;
    x.fctUnitStaies = fctUnitStaies;
    return x
  )

end 
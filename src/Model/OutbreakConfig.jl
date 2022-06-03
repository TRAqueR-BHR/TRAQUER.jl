mutable struct OutbreakConfig <: IOutbreakConfig 

  id::Union{Missing,String}
  outbreakConfigUnitAssoes::Union{Missing,Vector{Model.IOutbreakConfigUnitAsso}}

  OutbreakConfig(args::NamedTuple) = OutbreakConfig(;args...)
  OutbreakConfig(;
    id = missing,
    outbreakConfigUnitAssoes = missing,
  ) = begin
    x = new(missing,missing,)
    x.id = id
    x.outbreakConfigUnitAssoes = outbreakConfigUnitAssoes
    return x
  end

end 
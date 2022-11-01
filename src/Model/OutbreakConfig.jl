mutable struct OutbreakConfig <: IOutbreakConfig 

  id::Union{Missing,String}
  isEpidemic::Union{Missing,Bool}
  outbreakConfigUnitAssoes::Union{Missing,Vector{Model.IOutbreakConfigUnitAsso}}
  outbreaks::Union{Missing,Vector{Model.IOutbreak}}

  OutbreakConfig(args::NamedTuple) = OutbreakConfig(;args...)
  OutbreakConfig(;
    id = missing,
    isEpidemic = missing,
    outbreakConfigUnitAssoes = missing,
    outbreaks = missing,
  ) = begin
    x = new(missing,missing,missing,missing,)
    x.id = id
    x.isEpidemic = isEpidemic
    x.outbreakConfigUnitAssoes = outbreakConfigUnitAssoes
    x.outbreaks = outbreaks
    return x
  end

end 
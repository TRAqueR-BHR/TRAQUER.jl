mutable struct AnalysisTypeDeprecated <: IAnalysisTypeDeprecated 

  id::Union{Missing,String}
  name::Union{Missing,String}
  codeName::Union{Missing,String}

  AnalysisTypeDeprecated(args::NamedTuple) = AnalysisTypeDeprecated(;args...)
  AnalysisTypeDeprecated(;
    id = missing,
    name = missing,
    codeName = missing,
  ) = begin
    x = new(missing,missing,missing,)
    x.id = id
    x.name = name
    x.codeName = codeName
    return x
  end

end 
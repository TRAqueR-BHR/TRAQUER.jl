mutable struct AnalysisType <: IAnalysisType 

  id::Union{Missing,String}
  name::Union{Missing,String}
  codeName::Union{Missing,String}
  analyses::Union{Missing,Vector{Model.IAnalysis}}

  AnalysisType(args::NamedTuple) = AnalysisType(;args...)
  AnalysisType(;
    id = missing,
    name = missing,
    codeName = missing,
    analyses = missing,
  ) = (
    x = new(missing,missing,missing,missing,);
    x.id = id;
    x.name = name;
    x.codeName = codeName;
    x.analyses = analyses;
    return x
  )

end 
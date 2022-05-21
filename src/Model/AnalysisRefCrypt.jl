mutable struct AnalysisRefCrypt <: IAnalysisRefCrypt 

  id::Union{Missing,String}
  oneChar::Union{Missing,String}
  refCrypt::Union{Missing,Vector{UInt8}}
  analyses::Union{Missing,Vector{Model.IAnalysis}}

  AnalysisRefCrypt(args::NamedTuple) = AnalysisRefCrypt(;args...)
  AnalysisRefCrypt(;
    id = missing,
    oneChar = missing,
    refCrypt = missing,
    analyses = missing,
  ) = begin
    x = new(missing,missing,missing,missing,)
    x.id = id
    x.oneChar = oneChar
    x.refCrypt = refCrypt
    x.analyses = analyses
    return x
  end

end 
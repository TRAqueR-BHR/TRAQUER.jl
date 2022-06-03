mutable struct AnalysisRefCrypt <: IAnalysisRefCrypt 

  id::Union{Missing,String}
  oneChar::Union{Missing,String}
  refCrypt::Union{Missing,Vector{UInt8}}
  analysisResults::Union{Missing,Vector{Model.IAnalysisResult}}

  AnalysisRefCrypt(args::NamedTuple) = AnalysisRefCrypt(;args...)
  AnalysisRefCrypt(;
    id = missing,
    oneChar = missing,
    refCrypt = missing,
    analysisResults = missing,
  ) = begin
    x = new(missing,missing,missing,missing,)
    x.id = id
    x.oneChar = oneChar
    x.refCrypt = refCrypt
    x.analysisResults = analysisResults
    return x
  end

end 
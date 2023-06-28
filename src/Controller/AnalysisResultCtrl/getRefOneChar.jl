function AnalysisResultCtrl.getRefOneChar(ref::AbstractString)
    refOneChar = lowercase(last(ref))
    return refOneChar
end

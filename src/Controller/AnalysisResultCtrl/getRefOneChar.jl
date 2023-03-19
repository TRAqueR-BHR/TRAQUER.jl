function AnalysisResultCtrl.getRefOneChar(ref::String)
    refOneChar = lowercase(last(ref))
    return refOneChar
end

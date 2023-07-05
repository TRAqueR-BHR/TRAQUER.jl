function Custom.convertStringInInputFileToANALYSIS_REQUEST_TYPE(str::AbstractString)
    if str == "GXEPC"
        return Enum.AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae
    elseif str == "GXERV"
        return Enum.AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus
    elseif str == "PREPC"
        return Enum.AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae
    elseif str == "PRVRE"
        return Enum.AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus
    else
        error("Unknown ANALYSIS_REQUEST_TYPE[$str]")
    end
end

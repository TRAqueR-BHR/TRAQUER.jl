function Custom.convertStringInInputFileToANALYSIS_RESULT_VALUE_TYPE(
    analysisResult::AbstractString,
    requestType::ANALYSIS_REQUEST_TYPE
)

    if requestType == AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae
        if analysisResult ∈ ["A","NEPC"]
            return AnalysisResultValueType.negative
        else
            return AnalysisResultValueType.positive
        end
    elseif requestType == AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus
        if analysisResult ∈ ["A","NB"]
            return AnalysisResultValueType.negative
        else
            return AnalysisResultValueType.positive
        end
    elseif requestType ∈ [
        AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae,
        AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus
    ]
        if analysisResult ∈ ["N"]
            return AnalysisResultValueType.negative
        else
            return AnalysisResultValueType.positive
        end
    end


end

function TRAQUERUtil.getMappingAnalysisRequestType2InfectiousAgentCategory()

    Dict(
        AnalysisRequestType.molecular_analysis_carbapenemase_producing_enterobacteriaceae =>
            InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,

        AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae =>
            InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,

        AnalysisRequestType.molecular_analysis_vancomycin_resistant_enterococcus =>
            InfectiousAgentCategory.vancomycin_resistant_enterococcus,

        AnalysisRequestType.bacterial_culture_vancomycin_resistant_enterococcus =>
            InfectiousAgentCategory.vancomycin_resistant_enterococcus,
    )

end

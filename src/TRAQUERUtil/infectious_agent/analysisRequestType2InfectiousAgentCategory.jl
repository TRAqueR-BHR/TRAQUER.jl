function TRAQUERUtil.analysisRequestType2InfectiousAgentCategory(
    requestType::ANALYSIS_REQUEST_TYPE
)::INFECTIOUS_AGENT_CATEGORY

    TRAQUERUtil.getMappingAnalysisRequestType2InfectiousAgentCategory()[requestType]

end

function TRAQUERUtil.infectiousAgentCategory2AnalysisRequestTypes(
    infectiousAgent::INFECTIOUS_AGENT_CATEGORY
)::Vector{ANALYSIS_REQUEST_TYPE}

    TRAQUERUtil.getMappingAnalysisRequestType2InfectiousAgentCategory() |>
    n -> filter(kv -> last(kv) == infectiousAgent, n) |>
    keys |>
    collect

end

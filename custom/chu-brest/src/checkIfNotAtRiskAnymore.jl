function Custom.checkIfNotAtRiskAnymore(
    infectiousStatuses::Vector{InfectiousStatus},
    analyses::Vector{AnalysisResult},
    infectiousAgent::INFECTIOUS_AGENT_CATEGORY
)::Union{Missing, InfectiousStatus}

    InfectiousStatusCtrl.defaultCheckIfNotAtRiskAnymore(
        infectiousStatuses, analyses, infectiousAgent
    )

end

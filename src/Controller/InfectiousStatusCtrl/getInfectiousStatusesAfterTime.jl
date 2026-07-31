function InfectiousStatusCtrl.getInfectiousStatusesAfterTime(
    patient::Patient,
    timeOfInterest::ZonedDateTime,
    retrieveComplexProps::Bool,
    dbconn::LibPQ.Connection
    ;statusesOfInterest::Union{Missing,Vector{InfectiousStatusType.INFECTIOUS_STATUS_TYPE}} = missing,
    infectiousAgentsOfInterest::Union{Missing,Vector{InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY}}
)::Vector{InfectiousStatus}

    result = InfectiousStatus[]
    infectiousAgents = if ismissing(infectiousAgentsOfInterest)
        instances(InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY)
    else
        infectiousAgentsOfInterest
    end

    for infectiousAgent in infectiousAgents
        statusAtTime = InfectiousStatusCtrl.getInfectiousStatusAfterTime(
            patient,
            infectiousAgent,
            timeOfInterest,
            retrieveComplexProps,
            dbconn
            ;statusesOfInterest = statusesOfInterest
        )
        if !ismissing(statusAtTime)
            push!(result, statusAtTime)
        end
    end

    return result

end

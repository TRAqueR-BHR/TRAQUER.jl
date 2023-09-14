function InfectiousStatusCtrl.getInfectiousStatusesAtTime(
    patient::Patient,
    timeOfInterest::ZonedDateTime,
    retrieveComplexProps::Bool,
    dbconn::LibPQ.Connection
    ;statusesOfInterest::Union{Missing,Vector{InfectiousStatusType.INFECTIOUS_STATUS_TYPE}} = missing
)::Vector{InfectiousStatus}

    result = InfectiousStatus[]
    for infectiousAgent in instances(InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY)
        statusAtTime = InfectiousStatusCtrl.getInfectiousStatusAtTime(
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

function InfectiousStatusCtrl.defaultCheckIfNotAtRiskAnymore(
    infectiousStatuses::Vector{InfectiousStatus},
    analyses::Vector{AnalysisResult},
    infectiousAgent::INFECTIOUS_AGENT_CATEGORY
)::Union{Missing, InfectiousStatus}

    requestTypes = TRAQUERUtil.infectiousAgentCategory2AnalysisRequestTypes(infectiousAgent)

    # ############################################# #
    # A few sanity checks (some may throw an error) #
    # ############################################# #
    infectiousStatuses = filter(x -> x.infectiousAgent === infectiousAgent, infectiousStatuses)
    analyses = filter(x -> x.requestType ∈ requestTypes, analyses)

    sort!(infectiousStatuses, by = x -> x.refTime)
    sort!(analyses, by = x -> x.requestTime)

    # If the patient has no analyses or no infectious status for this particular agent
    #   then return missing
    if isempty(analyses) || isempty(infectiousStatuses)
        return missing
    end

    lastInfectiousStatus = last(infectiousStatuses)


    # NOTE: it is > not >= because the infectiousRef time can be the requestTime of the
    # analysis that originated the status...and we are not interested in this analysis
    negativeAnalysesAfterLastInfectiousStatus = filter(
        x -> (
                x.requestTime > lastInfectiousStatus.refTime
                && x.result === AnalysisResultValueType.negative
            ),
        analyses
    )

    waitingPeriodForCarrier =
        TRAQUERUtil.getCarrierWaitingPeriod()
    numberOfNegativeTestsForCarrierExclusion =
        TRAQUERUtil.getNumberOfNegativeTestsForCarrierExclusion()
    numberOfNegativeTestsForContactExclusion =
        TRAQUERUtil.getNumberOfNegativeTestsForContactExclusion()

    currentStatus::Union{Missing, INFECTIOUS_STATUS_TYPE} = missing

    if lastInfectiousStatus.infectiousStatus == InfectiousStatusType.contact

        if length(negativeAnalysesAfterLastInfectiousStatus) >= numberOfNegativeTestsForContactExclusion
            currentStatus = InfectiousStatusType.not_at_risk
        else
            currentStatus = InfectiousStatusType.contact
        end

    elseif lastInfectiousStatus.infectiousStatus == InfectiousStatusType.carrier

        # Only interested in the negative analyses after the waiting period
        negativeAnalysesAfterWaitingPeriod = filter!(
            x -> (
                    x.requestTime >= lastInfectiousStatus.refTime + waitingPeriodForCarrier
                    && x.result === AnalysisResultValueType.negative
                ),
                negativeAnalysesAfterLastInfectiousStatus
        )

        if length(negativeAnalysesAfterWaitingPeriod) >= numberOfNegativeTestsForCarrierExclusion
            currentStatus = InfectiousStatusType.not_at_risk
        else
            currentStatus = InfectiousStatusType.carrier
        end

    else
        currentStatus = InfectiousStatusType.not_at_risk
    end

    if currentStatus != InfectiousStatusType.not_at_risk
        return lastInfectiousStatus
    else
        return InfectiousStatus(
            infectiousAgent = infectiousAgent,
            infectiousStatus = InfectiousStatusType.not_at_risk,
            refTime = last(analyses).requestTime,
            isConfirmed = false,
        )
    end


end

"""
    InfectiousStatusCtrl.defaultCheckIfNotAtRiskAnymore(
        infectiousStatuses::Vector{InfectiousStatus},
        analyses::Vector{AnalysisResult},
        infectiousAgent::INFECTIOUS_AGENT_CATEGORY
    )::Union{Missing, InfectiousStatus}

Checks whether a 'at risk' patient is still at risk by either returning the 'still at risk'
infectious status or a new (not serialized) instance of not_at_risk.

  * If the last infectious status found in the database is carrier/contact then we check if the
analyses allow to set the patient back to 'not at risk', in which case we return a new
instance of a not_at_risk InfectiousStatus that the calling function can serialize.
  * If last infectious status found in the database is not_at_risk then return it.
  * If no infectious status found return missing

**NOTES:**
  * This function is more meant to be called on a patient that is at risk
"""
function InfectiousStatusCtrl.defaultCheckIfNotAtRiskAnymore(
    infectiousStatuses::Vector{InfectiousStatus},
    analyses::Vector{AnalysisResult},
    infectiousAgent::INFECTIOUS_AGENT_CATEGORY
)::Union{Missing, InfectiousStatus}

    requestTypes = TRAQUERUtil.infectiousAgentCategory2AnalysisRequestTypes(infectiousAgent)

    # ##################################### #
    # Get last serialized infectious status #
    # ##################################### #
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

    # #################################################################################### #
    # Determine whether the patient is still at risk                                       #
    # NOTE: If the last infectious status found in the database is 'not_at_risk' return it #
    # #################################################################################### #
    currentStatus::Union{Missing, INFECTIOUS_STATUS_TYPE} = missing
    if lastInfectiousStatus.infectiousStatus == InfectiousStatusType.contact

        if length(negativeAnalysesAfterLastInfectiousStatus) >= numberOfNegativeTestsForContactExclusion
            currentStatus = InfectiousStatusType.not_at_risk
        else
            currentStatus = InfectiousStatusType.contact
        end

    elseif lastInfectiousStatus.infectiousStatus == InfectiousStatusType.carrier

        # We want to start checking the negative analysis after the last time that the carrier
        # status was activated
        startingTime = skipmissing(
            [
                lastInfectiousStatus.refTime,
                lastInfectiousStatus.updatedRefTime
            ]
        ) |> collect |> maximum

        # Only interested in the negative analyses after the waiting period
        negativeAnalysesAfterWaitingPeriod = filter!(
            x -> (
                    x.requestTime >= startingTime + waitingPeriodForCarrier
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
        return lastInfectiousStatus
    end

    # ##################################################################### #
    # If patient is still at risk, return the last infectious status found  #
    # If not, instantiate a new infectious status                           #
    # ##################################################################### #
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

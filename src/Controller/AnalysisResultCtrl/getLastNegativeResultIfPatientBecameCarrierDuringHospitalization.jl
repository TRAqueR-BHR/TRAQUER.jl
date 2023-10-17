function AnalysisResultCtrl.getLastNegativeResultIfPatientBecameCarrierDuringHospitalization(
    stay::Stay,
    infectiousAgent::INFECTIOUS_AGENT_CATEGORY,
    dbconn::LibPQ.Connection
)::Union{Missing, AnalysisResult}

    # Get the status of the patient at the beginning of the hospitalization
    infectiousStatusAtHospitalization = InfectiousStatusCtrl.getInfectiousStatusAtTime(
        stay.patient,
        infectiousAgent,
        stay.hospitalizationInTime,
        false, # retrieveComplexProps::Bool,
        dbconn
    )

    # If patient was not at risk or just contact when hospitalized, look for a negative analysis
    if (
        ismissing(infectiousStatusAtHospitalization)
        || infectiousStatusAtHospitalization.infectiousStatus ∈
            [InfectiousStatusType.not_at_risk, InfectiousStatusType.contact]
    )

        lastNegativeResult = AnalysisResultCtrl.getLastNegativeResultWithinPeriod(
            atRiskStatus.patient,
            infectiousAgent,
            infectiousStatusStay.hospitalizationInTime,
            atRiskStatus.refTime,
            dbconn
        )

        return lastNegativeResult

    end

    return missing

end

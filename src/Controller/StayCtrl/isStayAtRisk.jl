function StayCtrl.isStayAtRisk(
    stay::Stay,
    atRiskStatus::InfectiousStatus,
    notAtRiskStatus::Union{InfectiousStatus,Missing}
)

    StayCtrl.isStayAtRisk(
        stay::Stay,
        atRiskStatus.refTime,
        passmissing(getproperty)(notAtRiskStatus,:refTime)
    )

end

function StayCtrl.isStayAtRisk(
    stay::Stay,
    atRiskStatusRefTime::ZonedDateTime,
    notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
)

    # If stay has ended before the status ref time then it is not at risk
    if !ismissing(stay.outTime) && stay.outTime < atRiskStatusRefTime
        return false
    end

    # If the patient has a 'not_at_risk' status then the stay must have ended before that date
    #    or has started before that date to be considered at risk
    if !ismissing(notAtRiskStatusRefTime)

        if (!ismissing(stay.outTime)
            && stay.outTime > notAtRiskStatusRefTime)
            return false
        end

        if stay.inTime > notAtRiskStatusRefTime
            return false
        end

    end

    # If not excluded by the previous test, then the stay can generate exposures
    return true

end

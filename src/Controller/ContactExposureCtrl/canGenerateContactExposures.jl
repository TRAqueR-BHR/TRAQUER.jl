function ContactExposureCtrl.canGenerateContactExposures(
    stay::Stay,
    carrierStatus::InfectiousStatus,
    notAtRiskStatus::Union{InfectiousStatus,Missing}
)

    ContactExposureCtrl.canGenerateContactExposures(
        stay::Stay,
        carrierStatus.refTime,
        passmissing(getproperty)(notAtRiskStatus,:refTime)
    )

end


function ContactExposureCtrl.canGenerateContactExposures(
    stay::Stay,
    carrierStatusRefTime::ZonedDateTime,
    notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
)

    rollbackForHospitalizationsAtRisk = TRAQUERUtil.getCarrierRollbackPeriodForHospitalizationsAtRisk()

    # Start by checking that the stay is not too old
    if stay.hospitalizationInTime < carrierStatusRefTime - rollbackForHospitalizationsAtRisk
        return false
    end

    # If the patient has a 'not_at_risk' status then the stay must have ended before that date
    #    or has started before that that date to be considered at risk
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

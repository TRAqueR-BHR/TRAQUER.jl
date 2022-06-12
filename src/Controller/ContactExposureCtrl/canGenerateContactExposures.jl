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

    if ismissing(notAtRiskStatusRefTime)
        if ismissing(stay.outTime)
            return true
        elseif stay.outTime >= carrierStatusRefTime
            return true
        else
            return false
        end

    # If not_at_risk ref time exists
    else
        if ismissing(stay.outTime)
            if stay.inTime <= notAtRiskStatusRefTime
                return true
            else
                return false
            end
        else
            if (
                (carrierStatusRefTime < stay.inTime < notAtRiskStatusRefTime)
                ||
                (carrierStatusRefTime < stay.outTime < notAtRiskStatusRefTime)
            )
                return true
            else
                return false
            end

        end

    end


end

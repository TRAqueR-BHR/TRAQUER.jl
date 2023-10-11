function ContactExposureCtrl.isExposureLongEnoughToGenerateContactStatus(
    exposure::ContactExposure
    ;minimumExpositionDuration::Dates.Period = TRAQUERUtil.getMinimumNumberOfHoursForContactStatusCreation()
)

    if ismissing(exposure.endTime)
        return true
    else
        return exposure.endTime - exposure.startTime >= minimumExpositionDuration
    end

end

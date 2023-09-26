function ContactExposureCtrl.getExactOverlap(
    carrierInTime::ZonedDateTime,
    carrierOutTime::Union{Missing, ZonedDateTime},
    contactInTime::ZonedDateTime,
    contactOutTime::Union{Missing, ZonedDateTime},
)::Tuple{Union{ZonedDateTime,Missing}, Union{ZonedDateTime, Missing}}


    overlapStart::Union{Missing,ZonedDateTime} = missing
    overlapEnd::Union{Missing,ZonedDateTime} = missing

    resultIfNoOverlap = (missing,missing)

    if !ismissing(carrierOutTime)

        # CASE1: Take the 2nd and 3rd of the sorted 4 dates
        if !ismissing(contactOutTime)

            # No overlap cases
            if carrierOutTime <= contactInTime || contactOutTime <= carrierInTime
                return resultIfNoOverlap
            end

            allDates = [
                carrierInTime,
                carrierOutTime,
                contactInTime,
                contactOutTime,
                ] |> sort
            overlapStart = allDates[2]
            overlapEnd = allDates[3]

        # CASE2: Take the 2nd and 3rd of the sorted 3 dates
        else

            # No overlap cases
            if carrierOutTime <= contactInTime
                return resultIfNoOverlap
            end

            allDates = [
                carrierInTime,
                carrierOutTime,
                contactInTime,
                ] |> sort
            overlapStart = allDates[2]
            overlapEnd = allDates[3]
        end

    else

        # CASE3: Take the 2nd and 3rd of the sorted 3 dates
        if !ismissing(contactOutTime)

            # No overlap cases
            if contactOutTime <= carrierInTime
                return resultIfNoOverlap
            end

            allDates = [
                carrierInTime,
                contactInTime,
                contactOutTime,
                ] |> sort
            overlapStart = allDates[2]
            overlapEnd = allDates[3]

        # CASE4: Take the 2nd of the sorted 2 dates
        else
            allDates = [
                carrierInTime,
                contactInTime,
                ] |> sort
            overlapStart = allDates[2]
        end

    end


    return overlapStart, overlapEnd
end

function ContactExposureCtrl.getExactOverlap(
    carrierStay::Stay,
    contactStay::Stay,
)::Tuple{ZonedDateTime, Union{ZonedDateTime, Missing}}

    return ContactExposureCtrl.getExactOverlap(
        carrierStay.inTime,
        carrierStay.outTime,
        contactStay.inTime,
        contactStay.outTime,
    )

end

function ContactExposureCtrl.getExactOverlap(
    carrierInTime::ZonedDateTime,
    carrierOutTime::Union{Missing, ZonedDateTime},
    contactStay::Stay,
)::Tuple{ZonedDateTime, Union{ZonedDateTime, Missing}}

    return ContactExposureCtrl.getExactOverlap(
        carrierInTime,
        carrierOutTime,
        contactStay.inTime,
        contactStay.outTime,
    )

end

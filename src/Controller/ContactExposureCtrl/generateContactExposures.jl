function ContactExposureCtrl.generateContactExposures(
    startDate::Date,dbconn::LibPQ.Connection
)

    queryString = "SELECT * FROM infectious_status i
                   WHERE i.infectious_status = ANY(\$1)
                    AND ref_time >= \$2
                    "
    queryArgs = [[InfectiousStatusType.carrier], startDate]
    infectiousStatuses = PostgresORM.execute_query_and_handle_result(
            queryString, InfectiousStatus, queryArgs, false, dbconn)

    for infectiousStatus in infectiousStatuses
        ContactExposureCtrl.generateContactExposures(infectiousStatus, dbconn)
    end

    return infectiousStatuses

end

function ContactExposureCtrl.generateContactExposures(
    infectiousStatus::InfectiousStatus, dbconn::LibPQ.Connection
)

    # Check that the infectiousStatus is a `carrier`
    if infectiousStatus.infectiousStatus != InfectiousStatusType.carrier
        return
    end

    # Get the relevant stays and units of the patient
    # TODO restrict the stays to a given period based on the refTime of the infectious state
    queryString = "
       SELECT s.*
       FROM stay s
       WHERE s.patient_id = \$1
    "
    queryArgs = [infectiousStatus.patient.id]
    carrierStays = PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        queryArgs,
        false,
        dbconn)

    exposures = ContactExposure[]
    for carrierStay in carrierStays
        push!(exposures, ContactExposureCtrl.generateContactExposures(carrierStay, dbconn)...)
    end

    exposures

end


function ContactExposureCtrl.generateContactExposures(
    carrierStay::Stay, dbconn::LibPQ.Connection
)

    # Find all patients staying in the same units at the same time
    #   i.e. One of the in_time or out_time of the carrier's stays falls inside someone else
    #         stays

    restrictionForPartition = carrierStay.inDate - Month(1)

    queryArgs = [
        restrictionForPartition, # for perf
        carrierStay.unit.id,
    ]

    queryString = "
        SELECT s.*
        FROM stay s
        WHERE s.in_date >= \$1 -- This is for performance, in order to take
                               --   advantage of the partitioning.
                               -- CAUTION: We need to take a large margin for \$1
        AND s.unit_id = \$2
    "

    if !ismissing(carrierStay.outTime)

        queryString *= "
            AND
                (
                    -- Get the overlapping stays with a begin/end datetime
                    -- Scenarios CASE 1:
                    --   carrier      [=================]
                    --   contact [=============]
                    --   contact                  [==============]

                    (  \$3 BETWEEN s.in_time AND s.out_time
                       OR \$4 BETWEEN s.in_time AND s.out_time
                    )

                     OR

                    -- Get the overlapping stays without an end datetime:
                    -- Scenarios CASE 2:
                    --   carrier      [=================]
                    --   contact [=========================
                    --   contact                  [========

                    (
                        \$4 >= s.in_time AND s.out_time IS NULL
                    )
                )

        "
        push!(queryArgs,[carrierStay.inTime, carrierStay.outTime]...)

    else

        queryString *= "
            AND (

                    -- Scenario CASE 3:
                    --   carrier       [======================
                    --   contact   [========]
                    --   contact          [========]
                    (\$3 <= s.out_time)

                    OR

                    -- Scenario CASE 4:
                    --   carrier       [======================
                    --   contact   [==========================
                    --   contact           [==================
                    (s.out_time IS NULL)
                )
        "
        push!(queryArgs,[carrierStay.inTime]...)

    end


    contactStays::Vector{Stay} = PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        queryArgs,
        false,
        dbconn)

    # Get the exact overlap
    exposures = ContactExposure[]
    for contactStay in contactStays

        overlapStart::Union{Missing,ZonedDateTime} = missing
        overlapEnd::Union{Missing,ZonedDateTime} = missing

        if !ismissing(carrierStay.outTime)

            # CASE1: Take the 2nd and 3rd of the sorted 4 dates
            if !ismissing(contactStay.outTime)
                allDates = [
                    carrierStay.inTime,
                    carrierStay.outTime,
                    contactStay.inTime,
                    contactStay.outTime,
                    ] |> sort
                overlapStart = allDates[2]
                overlapEnd = allDates[3]

            # CASE2: Take the 2nd of the sorted 3 dates
            else
                allDates = [
                    carrierStay.inTime,
                    carrierStay.outTime,
                    contactStay.inTime,
                    ] |> sort
                overlapStart = allDates[2]
            end

        else

            # CASE3: Take the 2nd and 3rd of the sorted 3 dates
            if !ismissing(contactStay.outTime)
                allDates = [
                    carrierStay.inTime,
                    contactStay.inTime,
                    contactStay.outTime,
                    ] |> sort
                overlapStart = allDates[2]
                overlapEnd = allDates[3]

            # CASE4: Take the 2nd of the sorted 2 dates
            else
                allDates = [
                    carrierStay.inTime,
                    contactStay.inTime,
                    ] |> sort
                overlapStart = allDates[2]
            end

        end

        push!(
            exposures,
            ContactExposure(
                unit = contactStay.unit,
                contact = contactStay.patient,
                carrier = carrierStay.patient,
                startTime = overlapStart,
                endTime = overlapEnd)
            )

    end

    return exposures

end

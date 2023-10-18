function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak,
    carrierStayUnit::Unit,
    lowerLimit::ZonedDateTime,
    upperTimeLimit::Union{ZonedDateTime,Missing},
    carrierStayRoom::Union{String,Missing},
    sameRoomOnly::Bool,
    dbconn::LibPQ.Connection
    ;carrier::Union{Missing,Patient} = missing,
    simulate::Bool = false,
    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation::Bool = false
)

    # Find all patients staying in the same units at the same time
    #   i.e. One of the in_time or out_time of the carrier's stays falls inside someone else
    #         stays

    # Restrict the search of the contacts' stays to a few months back.
    # Must be careful to rollback enough in order to not exclude stays of contacts that
    # arrived a long time before the carrier stay
    restrictionForPartition = lowerLimit - Month(6)

    queryArgs = [
        restrictionForPartition, # for perf
        carrierStayUnit.id,
    ]

    queryString = "
        SELECT s.*
        FROM stay s
        WHERE
            s.in_date >= \$1 -- This is for performance, in order to take
                             --   advantage of the partitioning.
                             -- CAUTION: We need to take a large margin for \$1
            AND s.unit_id = \$2
    "

    if !ismissing(upperTimeLimit)

        queryString *= "
            AND
                (
                    -- Get the overlapping stays with a begin/end datetime that partially
                    -- fall inside the carrier stay
                    -- Scenarios CASE 1:
                    --   carrier      [=================]
                    --   contact [=============]
                    --   contact                  [==============]

                    (
                        \$3 BETWEEN s.in_time AND s.out_time
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

                    OR

                    -- Get the overlapping stays with a begin/end datetime that completely
                    -- fall inside the carrier stay
                    -- Scenarios CASE 3:
                    --   carrier      [=================]
                    --   contact          [==========]
                    (
                        \$3 < s.in_time AND \$4 > s.out_time
                    )
                )

        "
        push!(queryArgs,[lowerLimit, upperTimeLimit]...)

    else

        queryString *= "
            AND (

                    -- Scenario CASE 4:
                    --   carrier       [======================
                    --   contact   [========]
                    --   contact          [========]
                    (\$3 <= s.out_time)

                    OR

                    -- Scenario CASE 5:
                    --   carrier       [======================
                    --   contact   [==========================
                    --   contact           [==================
                    (s.out_time IS NULL)
                )
        "
        push!(queryArgs,[lowerLimit]...)

    end

    contactStays::Vector{Stay} = PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        queryArgs,
        false,
        dbconn)

    # Check that the exposure is not with the carrier himself
    if !ismissing(carrier)
        filter!(
            s -> s.patient.id != carrier.id,
            contactStays
        )
    end

    # Filter on same room if needed
    if sameRoomOnly
        # If restriction on same room only that there is no room to filter then we consider that
        # that there is no exposure
        if ismissing(carrierStayRoom)
            contactStays = Stay[]
        else
            filter!(
                s -> s.unit.id == carrierStayUnit.id && s.room === carrierStayRoom,
                contactStays
            )
        end
    end

    # Get the exact overlap
    exposures = ContactExposure[]
    for contactStay in contactStays

        # Check that the contact patient was not already a carrier
        if InfectiousStatusCtrl.checkIfPatientIsCarrierAtTime(
            contactStay.patient,
            outbreak.infectiousAgent,
            contactStay.inTime,
            dbconn
        ) == true
            continue
        end

        overlapStart, overlapEnd = ContactExposureCtrl.getExactOverlap(
            lowerLimit,
            upperTimeLimit,
            contactStay,
        )

        push!(
            exposures,
            ContactExposure(
                outbreak = outbreak,
                unit = contactStay.unit,
                contact = contactStay.patient,
                carrier = carrier,
                startTime = overlapStart,
                endTime = overlapEnd)
        )

    end


    # Exclude the exposure that are too short if needed
    if excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation
        filter!(
            e -> ContactExposureCtrl.isExposureLongEnoughToGenerateContactStatus(e),
            exposures
        )
    end

    # Serialize if not simulate
    if !simulate
        ContactExposureCtrl.upsert!.(exposures, dbconn)
    end

    return exposures

end

function ContactExposureCtrl.generateContactExposures(
    asso::OutbreakUnitAsso,
    dbconn::LibPQ.Connection
    ;simulate::Bool = false,
    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation::Bool = false
)

    outbreak = PostgresORM.retrieve_one_entity(
        Outbreak(id = asso.outbreak.id),
        false,
        dbconn
    )

    exposures = ContactExposure[]

    carrierStays = StayCtrl.getCarriersOrContactsStays(
        asso,
        InfectiousStatusType.carrier,
        dbconn
    )

    # If there are no carrier stay in the asso, the asso is probably created from scratch
    #   by the user
    if isempty(carrierStays)
        error("It is Not supported to generate contact exposures without carriers stays")
        # push!(
        #     exposures,
        #     ContactExposureCtrl.generateContactExposures(
        #         outbreak,
        #         asso.unit,
        #         asso.startTime,
        #         asso.endTime,
        #         dbconn
        #         ;simulate = simulate,
        #         excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation =
        #             excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation
        #     )...
        # )
    else
        for carrierStay in carrierStays
            push!(
                exposures,
                ContactExposureCtrl.generateContactExposures(
                    outbreak,
                    carrierStay,
                    asso.sameRoomOnly,
                    dbconn
                    ;simulate = simulate,
                    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation =
                        excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation
                )...
            )
        end
    end

    return exposures

end

function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak, dbconn::LibPQ.Connection
    ;simulate::Bool = false,
    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation::Bool = false
)

    # Get the OutbreakUnitAssos
    outbreakUnitAssos = "SELECT oua.*
        FROM outbreak o
        JOIN outbreak_unit_asso oua
          ON oua.outbreak_id = o.id
        JOIN unit
          ON oua.unit_id = unit.id
        WHERE
        o.id = \$1
        " |> n -> PostgresORM.execute_query_and_handle_result(
                n,
                OutbreakUnitAsso,
                [outbreak.id],
                false,
                dbconn
            )

    exposures = ContactExposure[]
    for asso in outbreakUnitAssos
        push!(
            exposures,
            ContactExposureCtrl.generateContactExposures(
                asso, dbconn
                ;simulate = simulate,
                excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation =
                    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation
            )...)
    end

    return exposures

end

"""
"""
function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak,
    unit::Unit,
    startTime::ZonedDateTime,
    endTime::ZonedDateTime,
    dbconn::LibPQ.Connection
    ;simulate::Bool = false,
    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation::Bool = false
)

    return ContactExposureCtrl.generateContactExposures(
        outbreak,
        unit,
        startTime,
        endTime,
        missing, # room
        false, # sameRoomOnly::Bool,
        dbconn
        ;simulate = simulate,
        excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation =
                    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation
    )

end




function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak, carrierStay::Stay, sameRoomOnly::Bool, dbconn::LibPQ.Connection
    ;simulate::Bool = false,
    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation::Bool = false
)

    # #################################################################################### #
    # Compute the upper limit                                                              #
    # Upper limit of exposures is either the out time of the unit or the isolation time    #
    # #################################################################################### #
    upperTime = if !ismissing(carrierStay.isolationTime)
            carrierStay.isolationTime
        else
            carrierStay.outTime
        end

    # ########### #
    # Lower limit #
    # ########### #

    # Initialize lower limit with carrier stay in time
    lowerLimit = carrierStay.inTime

    lastNegativeResultIfPatientBecameCarrierDuringHospitalization =
        AnalysisResultCtrl.getLastNegativeResultIfPatientBecameCarrierDuringHospitalization(
            carrierStay,
            outbreak.infectiousAgent,
            dbconn
        )
    # If patient was not at risk when entering the hospital and that he turned carrier during
    # the hospitalization after having some negative tests, use the last negative test as
    # the lower limit
    if !ismissing(lastNegativeResultIfPatientBecameCarrierDuringHospitalization)
        # If the stay is the one where the patient was last negative use the request time
        # as the lower limit plus one day (we consider that the patient cannot have turned
        # positive on the same day that he was tested negative)
        if (
            lastNegativeResultIfPatientBecameCarrierDuringHospitalization.requestTime > carrierStay.inTime
            && !ismissing(carrierStay.outTime)
            && lastNegativeResultIfPatientBecameCarrierDuringHospitalization.requestTime < carrierStay.outTime
        )
            lowerLimit = lastNegativeResultIfPatientBecameCarrierDuringHospitalization.requestTime + Day(1)
        end
    end


    return ContactExposureCtrl.generateContactExposures(
        outbreak,
        carrierStay.unit,
        lowerLimit,
        upperTime,
        carrierStay.room,
        sameRoomOnly,
        dbconn
        ;carrier = carrierStay.patient,
        simulate = simulate,
        excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation =
                    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation
    )

end

function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak,
    carrierStayUnit::Unit,
    carrierStayInTime::ZonedDateTime,
    carrierStayOutTime::Union{ZonedDateTime,Missing},
    carrierStayRoom::Union{String,Missing},
    sameRoomOnly::Bool,
    dbconn::LibPQ.Connection
    ;carrier::Union{Missing,Patient} = missing,
    simulate::Bool = false
)

    # Find all patients staying in the same units at the same time
    #   i.e. One of the in_time or out_time of the carrier's stays falls inside someone else
    #         stays

    # Restrict the search of the contacts' stays to a few months back.
    # Must be careful to rollback enough in order to not exclude stays of contacts that
    # arrived a long time before the carrier stay
    restrictionForPartition = carrierStayInTime - Month(6)

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

    if !ismissing(carrierStayOutTime)

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
        push!(queryArgs,[carrierStayInTime, carrierStayOutTime]...)

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
        push!(queryArgs,[carrierStayInTime]...)

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
            carrierStayInTime,
            carrierStayOutTime,
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

    if !simulate
        ContactExposureCtrl.upsert!.(exposures, dbconn)
    end

    return exposures

end

function ContactExposureCtrl.generateContactExposures(
    asso::OutbreakUnitAsso, dbconn::LibPQ.Connection
    ;simulate::Bool = false
)

    outbreak = PostgresORM.retrieve_one_entity(
        Outbreak(id = asso.outbreak.id),
        false,
        dbconn)

    exposures = ContactExposure[]

    carrierStays = StayCtrl.getCarriersOrContactsStays(asso, InfectiousStatusType.carrier ,dbconn)


    # If there are no carrier stay in the asso, the asso is probably created from scratch
    #   by the user
    if isempty(carrierStays)
        push!(
            exposures,
            ContactExposureCtrl.generateContactExposures(
                outbreak,
                asso.unit,
                asso.startTime,
                asso.endTime,
                dbconn
                ;simulate = simulate
            )...
        )
    else
        for carrierStay in carrierStays
            push!(
                exposures,
                ContactExposureCtrl.generateContactExposures(
                    outbreak, carrierStay, asso.sameRoomOnly, dbconn
                    ;simulate = simulate
                )...
            )
        end
    end

    return exposures

end

function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak, dbconn::LibPQ.Connection
    ;simulate::Bool = false
)

    # Get the OutbreakUnitAssos
    outbreakUnitAssos = "SELECT ocua.*
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
                ;simulate = simulate
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
    ;simulate::Bool = false
)

    return ContactExposureCtrl.generateContactExposures(
        outbreak,
        unit,
        startTime,
        endTime,
        missing, # room
        false, # sameRoomOnly::Bool,
        dbconn
    )

end




function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak, carrierStay::Stay, sameRoomOnly::Bool, dbconn::LibPQ.Connection
    ;simulate::Bool = false
)

    return ContactExposureCtrl.generateContactExposures(
        outbreak,
        carrierStay.unit,
        carrierStay.inTime,
        carrierStay.outTime,
        carrierStay.room,
        sameRoomOnly,
        dbconn
        ;carrier = carrierStay.patient,
        simulate = simulate
    )

end

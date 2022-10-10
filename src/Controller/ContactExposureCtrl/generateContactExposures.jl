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

    restrictionForPartition = carrierStayInTime - Month(1)

    queryArgs = [
        restrictionForPartition, # for perf
        carrierStayUnit.id,
    ]

    queryString = "
        SELECT s.*
        FROM stay s
        WHERE s.in_date >= \$1 -- This is for performance, in order to take
                               --   advantage of the partitioning.
                               -- CAUTION: We need to take a large margin for \$1
        AND s.unit_id = \$2
    "

    if !ismissing(carrierStayOutTime)

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
        push!(queryArgs,[carrierStayInTime, carrierStayOutTime]...)

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
        push!(queryArgs,[carrierStayInTime]...)

    end

    contactStays::Vector{Stay} = PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        queryArgs,
        false,
        dbconn)

    @info "DEBUG1 unit[$(carrierStayUnit.name)] length(contactStays)[$(length(contactStays))]"

    # Check that the exposure is not with the carrier himself
    if !ismissing(carrier)
        filter!(
            s -> s.patient.id != carrier.id,
            contactStays
        )
    end

    @info "DEBUG2 unit[$(carrierStayUnit.name)] length(contactStays)[$(length(contactStays))]"

    # Only keep the stays for the same room if needed
    if sameRoomOnly && !ismissing(carrierStayRoom)
        filter!(
            s -> s.unit.id == carrierStayUnit.id && s.room === carrierStayRoom,
            contactStays
        )
    end

    @info "DEBUG3 unit[$(carrierStayUnit.name)] length(contactStays)[$(length(contactStays))]"

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
    asso::OutbreakConfigUnitAsso, dbconn::LibPQ.Connection
    ;simulate::Bool = false
)

    @warn "HERE1"

    outbreak = PostgresORM.retrieve_one_entity(
        Outbreak(config = OutbreakConfig(id = asso.outbreakConfig.id)),
        false,
        dbconn)

    exposures = ContactExposure[]

    carrierStays = StayCtrl.getCarriersStays(asso, dbconn)

    # 1. Create the exposures for the carriers stays
    for carrierStay in carrierStays
        push!(
            exposures,
            ContactExposureCtrl.generateContactExposures(
                outbreak, carrierStay, asso.sameRoomOnly, dbconn
                ;simulate = simulate
            )...
        )
    end

    # 2. Create some additional exposures if the time boundaries are larger than the stays

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
    # If there are some carrier stays only create additional exposures if the boudaries
    # of the asso are larger than the ones of the stays
    else

        minInTimeCarrierStayInUnit = getproperty.(carrierStays, :inTime) |>
            minimum # can return missing
        maxOutTimeCarrierStayInUnit = filter(x -> !ismissing(x.outTime),carrierStays) |>
            n -> if isempty(n) missing else map(x -> x.outTime,n) end |>
            passmissing(maximum) # can return missing

        if (
            asso.startTime < minInTimeCarrierStayInUnit
            || (
                !ismissing(maxOutTimeCarrierStayInUnit)
                && !ismissing(asso.endTime)
                && asso.endTime > maxOutTimeCarrierStayInUnit
            )
        )
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
        end

    end


    return exposures

end

function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak, dbconn::LibPQ.Connection
    ;simulate::Bool = false
)

    # Get the OutbreakConfigUnitAssos
    outbreakConfigUnitAssos = "SELECT ocua.*
        FROM outbreak o
        JOIN outbreak_config oc
        ON o.config_id = oc.id
        JOIN outbreak_config_unit_asso ocua
        ON ocua.outbreak_config_id = oc.id
        JOIN unit
        ON ocua.unit_id = unit.id
        WHERE
        o.id = \$1
        " |> n -> PostgresORM.execute_query_and_handle_result(
                n,
                OutbreakConfigUnitAsso,
                [outbreak.id],
                false,
                dbconn
            )

    exposures = ContactExposure[]
    for asso in outbreakConfigUnitAssos
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

function ContactExposureCtrl.generateContactExposures(
    startDate::Date,dbconn::LibPQ.Connection
)

    queryString = "
        SELECT * FROM infectious_status i
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
    outbreak::Outbreak,
    dbconn::LibPQ.Connection)

    # Get the confirmed carrier infectious status of the outbreak
    queryString = "
        SELECT ist.*
        FROM outbreak
        JOIN outbreak_infectious_status_asso oisa
          ON  oisa.outbreak_id = outbreak.id
        JOIN infectious_status ist
          ON ist.id = oisa.infectious_status_id
        WHERE ist.infectious_status = 'carrier'
        AND ist.is_confirmed = 'true'
        "
    confirmedCarrierInfectiousStatuses = PostgresORM.execute_query_and_handle_result(
        queryString,InfectiousStatus, missing, false , dbconn
    )

    @info "length(confirmedCarrierInfectiousStatuses)[$(length(confirmedCarrierInfectiousStatuses))]"

    exposures = ContactExposure[]
    # Generate the contact exposures for same unit or same room
    for infectiousStatus in confirmedCarrierInfectiousStatuses
        push!(
            exposures,
            ContactExposureCtrl.generateContactExposures(
                outbreak,
                infectiousStatus,
                dbconn
            )...
        )
    end

    # Generate the additional exposures
    push!(
        exposures,
        ContactExposureCtrl.generateAdditionalContactExposures(
            outbreak, dbconn
        )...
    )

    return exposures

end

function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak,
    carrierInfectiousStatus::InfectiousStatus,
    dbconn::LibPQ.Connection
)

    # Check that the infectiousStatus is a confirmed carrier
    if (carrierInfectiousStatus.infectiousStatus !== InfectiousStatusType.carrier
        || carrierInfectiousStatus.isConfirmed !== true)
        return
    end

    # Get the configuration
    outbreakConfig = PostgresORM.retrieve_one_entity(outbreak.config,false,dbconn)

    # Look for an infectious status 'not_at_risk' after the 'carrier' ref. time for this
    # same infectious agent. It will allow to exclude the stays that started after the
    # ref. time of this 'not_at_risk' status
    notAtRiskStatus = "
        SELECT ist.*
        FROM infectious_status ist
        WHERE ist.patient_id = \$1
            AND ist.infectious_agent = \$2
            AND ist.infectious_status = 'not_at_risk'
            AND ist.ref_time > \$3
        ORDER BY ist.ref_time
        LIMIT 1
        " |>
        n -> PostgresORM.execute_query_and_handle_result(
                n,
                InfectiousStatus,
                [
                    carrierInfectiousStatus.patient.id,
                    carrierInfectiousStatus.infectiousAgent,
                    carrierInfectiousStatus.refTime
                ],
                false,
                dbconn
            ) |> n -> if isempty(n) missing else first(1) end

    # ################################################################################### #
    # Get all stays of the carrier and keep the ones that can generate an exposure        #
    # ################################################################################### #
    queryString = "
       SELECT s.*
       FROM stay s
       WHERE s.patient_id = \$1
       ORDER BY s.in_time
    "
    queryArgs = [carrierInfectiousStatus.patient.id]
    carrierStays = PostgresORM.execute_query_and_handle_result(
        queryString,
        Stay,
        queryArgs,
        false,
        dbconn)

    # Only keep the stays that can generate exposures
    filter!(
        stay -> ContactExposureCtrl.canGenerateContactExposures(
                    stay,
                    carrierInfectiousStatus,
                    notAtRiskStatus
                ),
        carrierStays
    )

    # Generate the exposures
    exposures = ContactExposure[]
    @info "length(carrierStays)[$(length(carrierStays))]"
    for carrierStay in carrierStays
        push!(
            exposures,
            ContactExposureCtrl.generateContactExposures(
                outbreak, carrierStay, outbreakConfig.sameRoomOnly, dbconn)...
            )
    end

    exposures

end

function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak,
    carrierStayUnit::Unit,
    carrierStayInTime::ZonedDateTime,
    carrierStayOutTime::Union{ZonedDateTime,Missing},
    carrierStayRoom::Union{String,Missing},
    sameRoomOnly::Bool,
    dbconn::LibPQ.Connection
    ;carrier::Union{Missing,Patient} = missing
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

    # Only keep the stays for the same room if needed
    if sameRoomOnly && !ismissing(carrierStayRoom)
        filter!(
            s -> s.unit.id == carrierStayUnit.id && s.room === carrierStayRoom,
            contactStays
        )
    end

    # Get the exact overlap
    exposures = ContactExposure[]
    for contactStay in contactStays

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

    ContactExposureCtrl.upsert!.(exposures, dbconn)

    return exposures

end

function ContactExposureCtrl.generateContactExposures(
    outbreak::Outbreak, carrierStay::Stay, sameRoomOnly::Bool, dbconn::LibPQ.Connection
)

    return ContactExposureCtrl.generateContactExposures(
        outbreak,
        carrierStay.unit,
        carrierStay.inTime,
        carrierStay.outTime,
        carrierStay.room,
        sameRoomOnly,
        dbconn
        ;carrier = carrierStay.patient
    )

end

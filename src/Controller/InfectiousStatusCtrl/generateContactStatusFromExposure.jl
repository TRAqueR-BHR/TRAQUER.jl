function InfectiousStatusCtrl.generateContactStatusFromExposure(
    exposure::ContactExposure,
    dbconn::LibPQ.Connection)

    # @info "exposure.id[$(exposure.id)]"
    # if any(ismissing.(exposure.contact))
        exposure = PostgresORM.retrieve_one_entity(ContactExposure(id = exposure.id), true, dbconn)
    # end

    exposuresDF = "
        SELECT ce.contact_id,
               o.id as outbreak_id,
               ce.carrier_id,
               ce.start_time as exposure_start_time,
               o.infectious_agent
        FROM contact_exposure ce
        JOIN outbreak o
          ON ce.outbreak_id = o.id
        JOIN patient p
          ON ce.contact_id = p.id
        WHERE ce.id = \$1
        ORDER BY ce.start_time" |>
        n -> PostgresORM.execute_plain_query(
            n,
            [exposure.id],
            dbconn)

    # convert some of the columns
    exposuresDF.infectious_agent = TRAQUERUtil.string2enum.(
        INFECTIOUS_AGENT_CATEGORY, exposuresDF.infectious_agent)
    exposuresDF.contact = map(x -> Patient(id = x), exposuresDF.contact_id)

    patientInfectiousStatuses = InfectiousStatusCtrl.getInfectiousStatuses(
        exposure.contact, dbconn
    )

    for exposureRow in eachrow(exposuresDF)

        infectiousStatus = InfectiousStatus(
            patient = exposureRow.contact,
            infectiousAgent = exposureRow.infectious_agent,
            infectiousStatus = InfectiousStatusType.contact,
            refTime = exposureRow.exposure_start_time,
            isConfirmed = false,
        )

        # Check that the patient is not already a carrier for this infectious agent,
        #   i.e. That the status just before it (<=) is not a carrier
        # Eg.
        #
        # Existing statuses:     🍎
        # New contact status:             🍋
        # Insert new contact?:          false
        #
        # Existing statuses:              🍎
        # New contact status:             🍋
        # Insert new contact?:          false
        #
        # Existing statuses:                     🍎
        # New contact status:             🍋
        # Insert new contact?:           true

        # Existing statuses:      🍋
        # New contact status:             🍋
        # Insert new contact?:           true

        statusJustBefore =
            patientInfectiousStatuses |>
            n -> filter(
                x -> (
                    x.infectiousAgent == infectiousStatus.infectiousAgent
                    && x.refTime <= infectiousStatus.refTime
                    ),
                n
            ) |> n -> if isempty(n) missing else last(n) end

        if (
            !ismissing(statusJustBefore)
            && statusJustBefore.infectiousStatus == InfectiousStatusType.carrier
            )
            continue
        end

        # Upsert
        InfectiousStatusCtrl.upsert!(infectiousStatus, dbconn)
        InfectiousStatusCtrl.upsert!(
            OutbreakInfectiousStatusAsso(
                infectiousStatus = infectiousStatus,
                outbreak = Outbreak(id = exposureRow.outbreak_id)
            ),
            dbconn
        )

    end

    # As always, refresh the current status of the patient
    InfectiousStatusCtrl.updateCurrentStatus(exposure.contact, dbconn)

    return nothing
end

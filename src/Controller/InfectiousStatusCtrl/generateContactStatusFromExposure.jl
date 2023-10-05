function InfectiousStatusCtrl.generateContactStatusFromExposure(
    exposure::ContactExposure,
    dbconn::LibPQ.Connection
)

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
        # Insert new contact?:           false (but update existing contact status)

        # Existing statuses:      🍏
        # New contact status:             🍋
        # Insert new contact?:           true

        statusJustBefore = InfectiousStatusCtrl.getInfectiousStatusAtTime(
            exposure.contact,
            infectiousStatus.infectiousAgent,
            infectiousStatus.refTime - Second(1), # We want the infectious status just
                                                          #  before the infectious status that
                                                          #  we could potentially create,
            false, # retrieveComplexProps::Bool,
            dbconn
        )

        if !ismissing(statusJustBefore)
            if statusJustBefore.infectiousStatus == InfectiousStatusType.carrier
                continue
            #  If a contact status already existed then just update the last ref. time
            elseif statusJustBefore.infectiousStatus == InfectiousStatusType.contact

                # Use the refTime to set the updatedRefTime
                infectiousStatus.updatedRefTime =  infectiousStatus.refTime

                # Set the property so that the upsert function does an update
                infectiousStatus.refTime = statusJustBefore.refTime
                infectiousStatus.id = statusJustBefore.id

            end
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

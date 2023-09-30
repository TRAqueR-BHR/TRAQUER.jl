function OutbreakCtrl.generateDefaultOutbreakUnitAssos(
    outbreak::Outbreak,
    simulate::Bool,
    dbconn::LibPQ.Connection
    ;cleanExisting::Bool = true
)::Vector{OutbreakUnitAsso}

    # Clean previously generated default assos
    # if cleanExisting
    #     PostgresORM.delete_entity_alike(
    #         OutbreakUnitAsso(
    #             outbreak = outbreak,
    #             isDefault = true
    #         ),
    #         dbconn
    #     )
    # end

    # Get the confirmed carrier infectious statuses of the outbreak
    queryString = "
    SELECT ist.*
    FROM outbreak
    JOIN outbreak_infectious_status_asso oisa
      ON  oisa.outbreak_id = outbreak.id
    JOIN infectious_status ist
      ON ist.id = oisa.infectious_status_id
    WHERE outbreak.id = \$1
      AND ist.infectious_status = 'carrier'
      AND ist.is_confirmed = 'true'
    "
    confirmedCarrierInfectiousStatuses = PostgresORM.execute_query_and_handle_result(
        queryString, InfectiousStatus, [outbreak.id], false, dbconn
    )

    if isempty(confirmedCarrierInfectiousStatuses)
        @warn "There are no confirmed carrier status for outbreak[$(outbreak.id)]"
    end

    defaultAssos = OutbreakUnitAsso[]

    # Generate the default associations of the outbreak to the units
    for carrierInfectiousStatus in confirmedCarrierInfectiousStatuses
        push!(
            defaultAssos,
            OutbreakCtrl.generateDefaultOutbreakUnitAssos(
                outbreak,
                carrierInfectiousStatus,
                simulate,
                dbconn
            )...
        )
    end

    return defaultAssos

end

function OutbreakCtrl.generateDefaultOutbreakUnitAssos(
    outbreak::Outbreak,
    carrierInfectiousStatus::InfectiousStatus,
    simulate::Bool,
    dbconn::LibPQ.Connection
)::Vector{OutbreakUnitAsso}

    atRiskStays = StayCtrl.getStaysWherePatientAtRisk(carrierInfectiousStatus, dbconn)

    defaultAssos = OutbreakUnitAsso[]

    # ################################################################### #
    # Create or update the outbreak-unit assos based on the carrier stays #
    # ################################################################### #
    for stay in atRiskStays

        # Check that the unit can be associated to an outbreak
        # First check that the properties of the unit are loaded
        if ismissing(stay.unit.canBeAssociatedToAnOutbreak)
            stay.unit = PostgresORM.retrieve_one_entity(Stay(id = stay.unit.id),false,dbconn)
        end
        if stay.unit.canBeAssociatedToAnOutbreak === false
            continue;
        end

        # An asso may already exists, update it if needed, we dont want to create several
        # assos to the same unit
        existingAsso = PostgresORM.retrieve_one_entity(
            OutbreakUnitAsso(
                unit = stay.unit,
                outbreak = outbreak
            ),
            false,
            dbconn
        )

        if !ismissing(existingAsso)

            # 1. Add the existing asso to the result
            push!(defaultAssos,existingAsso)

            existingAssoNeedsUpdate = false
            # 2. Extend the asso in the past if needed
            if stay.inTime < existingAsso.startTime
                existingAsso.startTime = stay.inTime
                existingAssoNeedsUpdate = true
            end

            # 3. Extend the asso in the future if needed
            # If the stay has no end and existing asso had one, then specify that the
            #   asso has no end
            if ismissing(stay.outTime) && !ismissing(existingAsso.endTime)
                existingAsso.endTime = missing
                existingAssoNeedsUpdate = true
            # If the stay has an end that is after the end of the existing asso, update
            elseif (!ismissing(stay.outTime)
                && !ismissing(existingAsso.endTime)
                && stay.outTime > existingAsso.endTime)
                existingAsso.endTime = stay.outTime
                existingAssoNeedsUpdate = true
            end

            # 4. Serialize the changes
            if existingAssoNeedsUpdate && !simulate
                PostgresORM.update_entity!(existingAsso,dbconn)
            end

        else

            newAsso = OutbreakUnitAsso(
                unit = stay.unit,
                outbreak = outbreak,
                startTime = stay.inTime,
                endTime = stay.outTime,
                sameRoomOnly = true,
                isDefault = true
            )

            push!(
                defaultAssos,
                newAsso
            )

            if !simulate
                PostgresORM.create_entity!(newAsso,dbconn)
            end

        end

    end

    # ################################################################## #
    # Generate the contact exposures and the contact infectious statuses #
    # ################################################################## #
    for asso in defaultAssos
        ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(asso, dbconn)
    end

    return defaultAssos

end

"""
    ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(dbconn::LibPQ.Connection)

Generate the contact exposures and associated infectious statuses for all carriers

NOTE: The OutbreakUnitAssos must exist in the database.
      See OutbreakCtrl.generateDefaultOutbreakUnitAssos(
            outbreak::Outbreak,
            carrierInfectiousStatus::InfectiousStatus,
            simulate::Bool,
            dbconn::LibPQ.Connection
          )
"""
function ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(
    dbconn::LibPQ.Connection
    ;hintOnWhatOutbreakUnitAssosToSelect::Union{Missing,Vector{Stay}} = missing
)

    # Get the outbreaks of all carriers
    queryString = "
    SELECT oua.*
    FROM patient p
    JOIN infectious_status ist
        ON ist.patient_id = p.id
    JOIN outbreak_infectious_status_asso oista
        ON oista.infectious_status_id = ist.id
    JOIN outbreak o
        ON o.id = oista.outbreak_id
    JOIN outbreak_unit_asso oua
        ON oua.outbreak_id = o.id
    WHERE ist.infectious_status = 'carrier'
    ORDER BY o.ref_time DESC -- Take the most recent outbreaks first, in the case where an
                            -- infectious status is linked to several outbreaks it will
                            -- create exposures for the most recent outbreak (reminder:
                            -- we prevent creating a duplicate exposure based on
                            -- carrier/contact/unit)
    "

    outbreakUnitAssos = PostgresORM.execute_query_and_handle_result(
        queryString, OutbreakUnitAsso, missing, false, dbconn
    )

    # Roughly filter out some of the associations
    if !ismissing(hintOnWhatOutbreakUnitAssosToSelect) && !isempty(hintOnWhatOutbreakUnitAssosToSelect)

        # Get the list of units IDs that have movements and the minimun inTime
        unitsIdsOfHintStays::Vector{String} = hintOnWhatOutbreakUnitAssosToSelect |>
            n -> getproperty.(n, :unit) |>
            n -> getproperty.(n, :id) |>
            unique
        minimumInTime::ZonedDateTime = hintOnWhatOutbreakUnitAssosToSelect |>
            n -> getproperty.(n, :inTime) |>
            minimum

        # Only keep the assos where the unit is among the ones of the stays given as hint
        filter!(
            oua -> oua.unit.id ∈ unitsIdsOfHintStays,
            outbreakUnitAssos
        )

        # Remove the assos that have an endTime before the minimum inTime of the stays given
        # as hint (i.e. we are not interested in the assos that ended before any of the stays)
        filter(
            oua -> begin
                if ismissing(oua.endTime)
                    return true
                end
                if oua.endTime <= minimumInTime
                    return false
                else
                    return true
                end
            end,
            outbreakUnitAssos
        )
    end

    if !ismissing(hintOnWhatOutbreakUnitAssosToSelect)
        # Keep the assos that overlap with at least one stay

        filter!(
            oua -> begin
                for s in hintOnWhatOutbreakUnitAssosToSelect

                    # Must be on the same unit
                    if s.unit.id != oua.unit.id
                        continue
                    end

                    if ContactExposureCtrl.getExactOverlap(
                        s.inTime,
                        s.outTime,
                        oua.startTime,
                        oua.endTime
                    ) !== (missing, missing)
                        return true
                    end
                end
                # No overlap found with any of the stays given as hint
                return false
            end,
            outbreakUnitAssos
        )

    end

    for asso in outbreakUnitAssos
        ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(asso, dbconn)
    end

end

function ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(
    asso::OutbreakUnitAsso, dbconn::LibPQ.Connection
)

    PostgresORM.update_entity!(asso, dbconn)

    exposures::Vector{ContactExposure} = ContactExposureCtrl.generateContactExposures(asso, dbconn)

    for exposure in exposures
        InfectiousStatusCtrl.generateContactStatusFromExposure(exposure,dbconn)
    end

end

function ContactExposureCtrl.refreshExposuresAndContactStatuses(
    outbreak::Outbreak, dbconn::LibPQ.Connection
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

    ContactExposureCtrl.refreshExposuresAndContactStatuses.(outbreakUnitAssos, dbconn)

end


function ContactExposureCtrl.refreshExposuresAndContactStatuses(
    outbreakUnitAsso::OutbreakUnitAsso,dbconn::LibPQ.Connection
)

    # Get the old list of exposures
    oldExposures = "SELECT ce.*
    FROM contact_exposure ce
    WHERE ce.outbreak_id = \$1
      AND ce.unit_id = \$2" |>
    n -> PostgresORM.execute_query_and_handle_result(
        n,
        ContactExposure,
        [outbreakUnitAsso.outbreak.id, outbreakUnitAsso.unit.id],
        false,
        dbconn
    )


    # Create the new list of exposures
    # NOTE: We want to generate all the exposures, even if they dont create a contact status
    newExposures = ContactExposureCtrl.generateContactExposures(outbreakUnitAsso, dbconn)

    newExposuresIds = getproperty.(newExposures, :id)

    # Delete deprecated exposures (also deletes the associated infectious status
    # thanks to DELETE ON CASCADE on the foreign key)
    for oldExposure in oldExposures
        if oldExposure.id ∉ newExposuresIds
            PostgresORM.delete_entity(oldExposure,dbconn)
        end
    end

    # Generate the contact statuses
    for exposure in newExposures
        InfectiousStatusCtrl.generateContactStatusFromExposure(exposure,dbconn)
    end

    # Check if these patients can be considered not_at_risk give the analyses found after
    # the exposure. NOTE: For convenience and because there is no risk to create duplicate
    # statuses thanks to the `upsert!` function and also no risk to recreate a deleted
    # status, use the same lower bound for all patients and use now for the upper bound
    patients = getproperty.(newExposures, :contact) |> n -> unique(x -> x.id, n)
    if !isempty(patients)
        lowerBound = getproperty.(newExposures, :startTime) |> minimum
        upperBound = now(getTimeZone())

        for patient in patients
            InfectiousStatusCtrl.generateNotAtRiskStatusesFromAnalyses(
                patient,
                (lowerBound, upperBound), # forAnalysesRequestsBetween::Tuple{Date,Date},
                dbconn
            )
        end
    end



end

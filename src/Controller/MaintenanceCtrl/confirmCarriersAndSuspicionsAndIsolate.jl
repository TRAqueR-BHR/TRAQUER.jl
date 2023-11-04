function MaintenanceCtrl.confirmCarriersAndSuspicionsAndIsolate(
    dbconn::LibPQ.Connection
    ;simulate::Bool = false
)

    # Get the list of carriers/suspicions
    carriersAndSuspicions = "
        SELECT ist.*
        FROM infectious_status ist
        WHERE ist.infectious_status = ANY(\$1)
        ORDER BY ist.patient_id, ist.ref_time" |>
        n -> PostgresORM.execute_query_and_handle_result(
            n,
            InfectiousStatus,
            [[InfectiousStatusType.carrier, InfectiousStatusType.suspicion]],
            false,
            dbconn
        )

    # Confirm their status
    for infectiousStatus in carriersAndSuspicions
        if infectiousStatus.isConfirmed !== false
            infectiousStatus.isConfirmed = true
            if !simulate
                InfectiousStatusCtrl.upsert!(
                    infectiousStatus,
                    dbconn
                )
            end
        end
    end

    # Get the corresponding patients
    patients = map(x -> x.patient, carriersAndSuspicions) |>
        n -> Base.unique(x -> x.id, n)

    # Get the stays of the patient
    for patient in patients
        stays = StayCtrl.getSortedPatientStays(
            patient, dbconn
        )

        # Keep the stays that are after the oldest carrier/suspicion status
        firstCarrierSuspicionStatus = filter(
                ist -> ist.patient.id == patient.id, carriersAndSuspicions
            ) |>
            first

        Base.filter!(x -> x.inTime >= firstCarrierSuspicionStatus.refTime, stays)

        # NOTE: this works because the stays are ordered
        firstStaysOfHospitalizations = Base.unique(x -> x.hospitalizationInTime, stays)

        for stay in firstStaysOfHospitalizations
            if !simulate
                StayCtrl.saveIsolationTime(
                    patient,
                    stay.inTime + Minute(1), # isolationTime::ZonedDateTime,
                    dbconn
                )
            end
        end

    end

end

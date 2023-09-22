function InfectiousStatusCtrl.generateNotAtRiskStatusForDeadPatient(
    stay::Stay,
    dbconn::LibPQ.Connection
)::Union{nothing,InfectiousStatus}

    if stay.patientDiedDuringStay !== true
        return
    end


    for ist in InfectiousStatusCtrl.getInfectiousStatusesAtTime(
        stay.patient,
        stay.inTime,
        false, # retrieveComplexProps::Bool,
        dbconn
    )::Vector{InfectiousStatus}

        if ist.infectiousStatus ∈ [InfectiousStatus.carrier, InfectiousStatus.contact]

            newStatus = InfectiousStatus(
                patient = stay.patient,
                infectiousAgent = ist.infectiousAgent,
                infectiousStatus = InfectiousStatusType.not_at_risk,
                refTime = if !ismissing((stay.outTime)) stay.inTime else stay.outTime end,
                isConfirmed = false,
            )

            # Upsert
            InfectiousStatusCtrl.upsert!(newStatus, dbconn)

            # As always, refresh the current status of the patient
            InfectiousStatusCtrl.updateCurrentStatus(stay.patient, dbconn)

        end

    end

end

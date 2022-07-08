function StayCtrl.updateCurrentHospitalizationStatus(
    patient::Patient, dbconn::LibPQ.Connection
)

    # Check that patient is loaded
    # if ismissing(patient.firstname)
    #     patient = PostgresORM.retrieve_one_entity(patient,false, dbconn)
    # end

    stays = StayCtrl.getSortedPatientStays(patient, dbconn)

    @info "length(stays)[$(length(stays))]"

    if isempty(stays)
        return
    end

    # Use the latest stay to update the status
    stay = last(stays)

    # If there is no hospitalization out time it means that the patient is hospitalized
    if ismissing(stay.hospitalizationOutTime)
        patient.isHospitalized = true
        patient.currentUnit = stay.unit
    else
        patient.isHospitalized = false
        patient.currentUnit = missing
    end

    @info patient

    PostgresORM.update_entity!(patient, dbconn)

    return patient

end

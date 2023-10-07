function PatientCtrl.createPatientIfNoExist(
    firstname::AbstractString,
    lastname::AbstractString,
    birthdate::Date,
    ref::AbstractString,
    encryptionStr::AbstractString,
    dbconn::LibPQ.Connection
)::Patient

    # Look for the patient
    patient::Union{Missing,Patient} =
        PatientCtrl.retrieveOnePatient(ref,
                                       encryptionStr,
                                       dbconn)

    # TODO: If a patient was manually created from the GUI without the hospital reference
    #         then we should try to find the patient using his lastname and birthdate

    # Create patient if missing
    if ismissing(patient)
        patient = PatientCtrl.createPatient(firstname,
                                           lastname,
                                           birthdate,
                                           ref,
                                           encryptionStr,
                                           dbconn)
    end

    return patient

end

function PatientCtrl.retrieveOnePatient(ref::AbstractString,
                                        encryptionStr::AbstractString,
                                        dbconn::LibPQ.Connection)

    patients = PatientCtrl.retrievePatientsFromRef(ref,
                                        encryptionStr,
                                        dbconn)
    if isempty(patients)
        return missing
    else
        first(patients)
    end
end

function PatientCtrl.retrieveOnePatient(firstname::AbstractString,
                                     lastname::AbstractString,
                                     birthdate::Date,
                                     encryptionStr::AbstractString,
                                     dbconn::LibPQ.Connection)

     patients = PatientCtrl.retrievePatients(firstname,
                                             lastname,
                                             birthdate,
                                             encryptionStr,
                                             dbconn)
     if isempty(patients)
         return missing
     else
         return first(patients)
     end

end

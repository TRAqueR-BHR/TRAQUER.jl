function PatientCtrl.retrieveOnePatient(ref::String,
                                        encryptionStr::String,
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

function PatientCtrl.retrieveOnePatient(firstname::String,
                                     lastname::String,
                                     birthdate::Date,
                                     encryptionStr::String,
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

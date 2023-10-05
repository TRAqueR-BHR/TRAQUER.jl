function StayCtrl.transformStaysForListing(
    stays::Vector{Stay},
    cryptStr::AbstractString,
    dbconn::LibPQ.Connection
)::DataFrame

    if isempty(stays)
        return DataFrame()
    end

    staysDF = DataFrame()
    patientDecryptDF = DataFrame()

    for stay in stays

        # Add row to the stays dataframe
        Base.push!(staysDF, stay, dbconn)

        # Add row to the patient decrypt dataframe
        patientDecrypt::PatientDecrypt = PatientCtrl.getPatientDecrypt(
            stay.patient,
            cryptStr,
            dbconn
        )
        Base.push!(patientDecryptDF, patientDecrypt, dbconn)

    end

    # Underscore the column names
    DataFrames.rename!(patientDecryptDF, StringCases.underscore.(names(patientDecryptDF)))
    DataFrames.rename!(staysDF, StringCases.underscore.(names(staysDF)))

    # Make the patients DF unique over the patient_id to avoid creating duplicates when
    #   doing the innerjoin
    unique!(patientDecryptDF,:patient_id)

    result = DataFrames.innerjoin(staysDF, patientDecryptDF, on = :patient_id)

    # Sort by descending in_time (like all other lists)
    sort!(result, :in_time, rev = true)

    return result

end

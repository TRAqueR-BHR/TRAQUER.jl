function StayCtrl.getCarriersStaysForListing(
    outbreakUnitAsso::OutbreakUnitAsso,
    cryptStr::String,
    dbconn::LibPQ.Connection
)
# ::DataFrame

    stays::Vector{Stay} = StayCtrl.getCarriersStays(
        outbreakUnitAsso,
        dbconn
    )
    @info "length(stays)[$(length(stays))]"

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

    DataFrames.innerjoin(staysDF, patientDecryptDF, on = :patient_id)

end

function StayCtrl.getCarriersStaysForListing(
    outbreakConfigUnitAsso::OutbreakConfigUnitAsso,
    cryptStr::String,
    dbconn::LibPQ.Connection
)
# ::DataFrame

    stays::Vector{Stay} = StayCtrl.getCarriersStays(
        outbreakConfigUnitAsso,
        dbconn
    )
    @info "length(stays)[$(length(stays))]"

    if isempty(stays)
        return DataFrame()
    end

    staysDF = DataFrame()
    patientDecryptDF = DataFrame()

    for stay in stays

        # Transform the stays to dataframe rows
        propsAsDict = PostgresORM.Controller.util_get_entity_props_for_db_actions(
            stay,
            dbconn,
            true # Include missing values
        )
        push!(
            staysDF, PostgresORM.PostgresORMUtil.dict2namedtuple(propsAsDict)
            ;promote = true
        )

        # Get the corresponding patient decrypt data in a dataframe
        patientDecrypt::PatientDecrypt = PatientCtrl.getPatientDecrypt(
            stay.patient,
            cryptStr,
            dbconn
        )
        push!(
            patientDecryptDF,
            patientDecrypt |>
                n -> PostgresORM.Controller.util_get_entity_props_for_db_actions(
                    n,
                    dbconn,
                    true # Include missing values
                ) |>
                PostgresORM.PostgresORMUtil.dict2namedtuple
            ;promote = true
        )

    end

    # Underscore the column names
    DataFrames.rename!(patientDecryptDF, StringCases.underscore.(names(patientDecryptDF)))
    DataFrames.rename!(staysDF, StringCases.underscore.(names(staysDF)))

    # Make the patients DF unique over the patient_id to avoid creating duplicates when
    #   doing the innerjoin
    unique!(patientDecryptDF,:patient_id)

    DataFrames.innerjoin(staysDF, patientDecryptDF, on = :patient_id)

end

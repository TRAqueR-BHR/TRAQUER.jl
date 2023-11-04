function MaintenanceCtrl.importExistingConfirmedStatuses(
    filePath::String,
    cryptStr::String,
    dbconn::LibPQ.Connection
)

    df = XLSX.readtable(filePath,1) |> DataFrame

    # return df

    # The columns of the dataframe may be of type Any even if the elements are of other types.
    # The following casting is a way to make sure that the columns are of the right type.
    df.patient_ref = string.(df.patient_ref)
    df.firstname = string.(df.firstname)
    df.lastname = string.(df.lastname)
    df.birthdate = Date.(df.birthdate)
    df.infectious_status_ref_time = ZonedDateTime.(
        DateTime.(df.infectious_status_ref_time),
        TRAQUERUtil.getTimeZone()
    )
    df.infectious_agent = TRAQUERUtil.string2enum.(
        InfectiousAgentCategory.INFECTIOUS_AGENT_CATEGORY, df.infectious_agent
    )
    df.infectious_status = TRAQUERUtil.string2enum.(
        InfectiousStatusType.INFECTIOUS_STATUS_TYPE, df.infectious_status
    )

    for r in eachrow(df)

        patient = PatientCtrl.createPatientIfNoExist(
            r.firstname,
            r.lastname,
            r.birthdate,
            r.patient_ref,
            cryptStr,
            dbconn
        )

        infectiousStatus = InfectiousStatus(
            patient = patient,
            infectiousAgent = r.infectious_agent,
            infectiousStatus = r.infectious_status,
            refTime = r.infectious_status_ref_time,
            isConfirmed = true,
        )

        InfectiousStatusCtrl.upsert!(
            infectiousStatus,
            dbconn
            ;setNewEventAsPending = false
        )

        InfectiousStatusCtrl.updateCurrentStatus(patient, dbconn)

    end

    return df

end

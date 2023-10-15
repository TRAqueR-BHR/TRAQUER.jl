function MaintenanceCtrl.resetDatabase(
    ;resetStays::Union{Missing,Bool} = missing,
    resetPatients::Union{Missing,Bool} = missing
)
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        MaintenanceCtrl.resetDatabase(
            dbconn
            ;resetStays = resetStays,
            resetPatients = resetPatients
        )
    end
end

function MaintenanceCtrl.resetDatabase(
    dbconn::LibPQ.Connection
    ;resetStays::Union{Missing,Bool} = missing,
    resetPatients::Union{Missing,Bool} = missing
)

    if ismissing(resetStays)
        error("The keyword argument 'resetStays' must be provided")
    end

    if ismissing(resetPatients)
        error("The keyword argument 'resetPatients' must be provided")
    end

    if !TRAQUERUtil.resetDatabaseIsAllowed()
        error(
            "You are trying to reset the database. The configuration doesnt allow that."
            *" If you really want to reset the database, set `allow_database_reset = true`"
            *" in the 'debug' section of the configuration file"
        )
    end

    if resetStays
        "DELETE FROM stay" |>
        n -> PostgresORM.execute_plain_query(n,missing,dbconn)
    end

    if resetPatients
        "DELETE FROM patient" |>
        n -> PostgresORM.execute_plain_query(n,missing,dbconn)
        "DELETE FROM patient_birthdate_crypt" |>
        n -> PostgresORM.execute_plain_query(n,missing,dbconn)
        "DELETE FROM patient_name_crypt" |>
        n -> PostgresORM.execute_plain_query(n,missing,dbconn)
        "DELETE FROM patient_ref_crypt" |>
        n -> PostgresORM.execute_plain_query(n,missing,dbconn)
    end

    "DELETE FROM analysis_request" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM analysis_result" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM analysis_ref_crypt" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM infectious_status" |> # also deletes entries in 'event_requiring_attention'
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM outbreak" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DELETE FROM contact_exposure" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    nothing

end

function TRAQUERUtil.dumpDatabaseAndCleanOldDumps()
    TRAQUERUtil.dumpDatabase()
    TRAQUERUtil.cleanOldDatabaseDumps()
end

function TRAQUERUtil.dumpDatabase(
    ;dumpFilePath::Union{String,Missing} = missing,
    schemaOnly::Bool = false
)
   

    # Get the connection details
    databaseName = TRAQUERUtil.getConf("database","database")
    user = TRAQUERUtil.getConf("database","user")
    host = TRAQUERUtil.getConf("database","host_for_dump")
    port = TRAQUERUtil.getConf("database","port_for_dump")
    

    # Build the dump file path if it was not given as an argument
    if ismissing(dumpFilePath)
        # Create the target directory if not exists
        targetDir = TRAQUERUtil.getDatabaseDumpDir()
        mkpath(targetDir)

        # Create the filename
        timestampSuffix = now(TRAQUERUtil.getTimezone()) |>
            n -> Dates.format(n,Dates.DateFormat("yyyy-mm-ddTHH:MM"))

        dumpFileName = if schemaOnly
            "$databaseName-schema-$timestampSuffix.dump"
        else
            "$databaseName-$timestampSuffix.dump"
        end

        dumpFilePath = joinpath(targetDir,dumpFileName)
    end

    # Dump
    cmd = if schemaOnly
        `pg_dump -Fc -s -h $host -p $port -U $user -f $dumpFilePath $databaseName`
    else
        `pg_dump -Fc -h $host -p $port -U $user -f $dumpFilePath $databaseName`
    end
    run(cmd)

    @info "Dump created at $dumpFilePath"

end


function TRAQUERUtil.cleanOldDatabaseDumps()

    for f in readdir(TRAQUERUtil.getDatabaseDumpDir(); join = true)

        dumpTime = mtime(f) |>
            Dates.unix2datetime |>
            n -> ZonedDateTime(n, tz"UTC") |>
            n -> astimezone(n, getTimezone())

        _now = now(getTimezone())
        retentionThreshold = _now - TRAQUERUtil.getDatabaseDumpRetentionPeriod()

        if dumpTime < retentionThreshold
            if endswith(f,".dump")
                rm(f; force = true)
            end
        end

    end

end


function TRAQUERUtil.getDatabaseDumpRetentionPeriod()
    Day(
        parse(
            Int8,
            getConf("database","dump_retention_in_days")
        )
    )
end

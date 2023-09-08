function TRAQUERUtil.dumpDatabase(schemaOnly::Bool;dumpFilePath::Union{String,Missing} = missing)

    # Get the connection details
    databaseName = TRAQUERUtil.getConf("database","database")
    user = TRAQUERUtil.getConf("database","user")
    host = TRAQUERUtil.getConf("database","host_for_dump")
    port = TRAQUERUtil.getConf("database","port_for_dump")

    # Create the filename
    timestampSuffix = now(TRAQUERUtil.getTimezone()) |>
        n -> Dates.format(n,Dates.DateFormat("yyyy-mm-ddTHH:MM"))

    dumpFileName = "$databaseName-$timestampSuffix.dump"

    # Build the dump file path if it was not given as an argument
    if ismissing(dumpFilePath)
        # Create the target directory if not exists
        targetDir = TRAQUERUtil.getDatabaseDumpDir()
        mkpath(targetDir)
        dumpFilePath = joinpath(targetDir,dumpFileName)
    end

    # Dump
    cmd = if schemaOnly
        `pg_dump --schema-only -Fc -h $host -p $port -U $user -f $dumpFilePath $databaseName`
    else
        `pg_dump -Fc -h $host -p $port -U $user -f $dumpFilePath $databaseName`
    end
    run(cmd)

end

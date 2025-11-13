include("../prerequisite.jl")
using LibPQ

projectVersion=Pkg.project().version |> string

function restoreDevDatabase(databaseName::String,dumpFilename::String)
    user = TRAQUERUtil.getConf("database","user")
    host = TRAQUERUtil.getConf("database","host_for_dump")
    port = TRAQUERUtil.getConf("database","port_for_dump")
    password = TRAQUERUtil.getConf("database","password")

    # Drop the database
    dbconn = LibPQ.Connection(
        "host=$(host)
        port=$(port)
        dbname=postgres
        user=$(user)
        password=$(password)"
        # ; throw_error=true
    )
    execute(dbconn, "DROP DATABASE IF EXISTS $databaseName")
    close(dbconn)

    # Create the database
    dbconn = LibPQ.Connection(
        "host=$(host)
        port=$(port)
        dbname=postgres
        user=$(user)
        password=$(password)"
        # ; throw_error=true
    )
    execute(dbconn, "CREATE DATABASE $databaseName TEMPLATE template0 OWNER $user;")
    close(dbconn)

    # Create the extension
    dbconn = LibPQ.Connection(
        "host=$(host)
        port=$(port)
        dbname=$(databaseName)
        user=$(user)
        password=$(password)"
        # ; throw_error=true
    )
    execute(dbconn, "CREATE EXTENSION IF NOT EXISTS pgcrypto;")
    execute(dbconn, "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\" ")
    close(dbconn)

    # Restore
    cmd = `pg_restore
    -h $host
    -p $port
    -d $databaseName
    --no-owner
    --username=$user
    --role=$user $dumpFilename`

    run(cmd)
end

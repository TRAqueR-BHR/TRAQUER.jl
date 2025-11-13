include("prerequisite.jl")

dumpFilename = "misc/dev-database-dumps/traquer-schema-0.1.5.dump"

TRAQUERUtil.createDBConnAndExecute() do dbconn
    """
    SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE datname = \$1
    AND pid <> pg_backend_pid();
    """ |>
       n -> PostgresORM.execute_plain_query(n,[TRAQUERUtil.getConf("database","database")],dbconn)
end

restoreDevDatabase(TRAQUERUtil.getConf("database","database"), dumpFilename)

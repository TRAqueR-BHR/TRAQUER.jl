function TRAQUERUtil.openDBConn()
    database = Conf.getConf("database","database")
    user = Conf.getConf("database","user")
    host = Conf.getConf("database","host")
    port = Conf.getConf("database","port")
    password = Conf.getConf("database","password")

    conn = LibPQ.Connection("host=$(host)
                             port=$(port)
                             dbname=$(database)
                             user=$(user)
                             password=$(password)
                             "; throw_error=true)

    execute(conn, "SET enable_partition_pruning = on;")
    execute(conn, "SET TIMEZONE='$(TRAQUERUtil.getTimeZoneAsStr())';")

    return conn
end

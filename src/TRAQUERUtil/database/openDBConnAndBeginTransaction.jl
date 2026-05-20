function TRAQUERUtil.openDBConnAndBeginTransaction()
    conn = TRAQUERUtil.openDBConn()
    TRAQUERUtil.beginDBTransaction(conn)
    return conn
end

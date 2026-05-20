function TRAQUERUtil.beginDBTransaction(conn)
    execute(conn, "BEGIN;")
end

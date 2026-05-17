function TRAQUERUtil.rollbackDBTransaction(conn)
    execute(conn, "ROLLBACK;")
end

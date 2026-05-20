function TRAQUERUtil.commitDBTransaction(conn)
    execute(conn, "COMMIT;")
end

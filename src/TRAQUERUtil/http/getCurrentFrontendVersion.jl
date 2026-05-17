function TRAQUERUtil.getCurrentFrontendVersion()

    dbconn = TRAQUERUtil.openDBConn()
    result = try
        query_string =
           "SELECT * FROM misc.frontend_version
            ORDER BY name DESC
            LIMIT 1
            "
        result = PostgresORM.
            execute_query_and_handle_result(query_string,
                                            FrontendVersion,
                                            [], # query_args
                                            false, # retrieve_complex_props
                                            dbconn)
        result
    catch e
        rethrow(e)
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end

    if isempty(result)
        return missing
    end

    return result[1]

end

include("../../prerequisite.jl")

using PostgresORM, LibPQ

# Create the enum 'grievance_type' first because we need to create the variables
dbconn = TRAQUERUtil.openDBConn()
try
    @info "
    # ################################################ #
    # Update etl.stay_extraction_scope table comment #
    # ################################################ #"

    """"
    COMMENT ON TABLE etl.stay_extraction_scope IS
        'Registry of scopes of stay data that are requested from the source system (the hospital information system) at a given time. For Adhoc extraction usage.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

catch e
    rethrow(e)
finally
    TRAQUERUtil.closeDBConn(dbconn)
end

@warn "
SUCCESS!
"

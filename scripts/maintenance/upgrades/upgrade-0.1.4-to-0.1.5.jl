include("../../prerequisite.jl")

using PostgresORM, LibPQ

# Create the enum 'grievance_type' first because we need to create the variables
dbconn = TRAQUERUtil.openDBConn()
try
    @info "
    # ################################### #
    # No database change for this version #
    # ################################### #"


catch e
    rethrow(e)
finally
    TRAQUERUtil.closeDBConn(dbconn)
end

@warn "
SUCCESS!
"

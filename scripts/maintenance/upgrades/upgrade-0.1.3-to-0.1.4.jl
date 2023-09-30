include("../../prerequisite.jl")

using PostgresORM, LibPQ

# Create the enum 'grievance_type' first because we need to create the variables
dbconn = TRAQUERUtil.openDBConn()
try
    @info "
    # ################################################ #
    # Add column unit.can_be_associated_to_an_outbreak #
    # ################################################ #"

    "ALTER TABLE unit ADD COLUMN IF NOT EXISTS can_be_associated_to_an_outbreak boolean DEFAULT true" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

catch e
    rethrow(e)
finally
    TRAQUERUtil.closeDBConn(dbconn)
end

@warn "
SUCCESS!
"

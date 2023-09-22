include("../../prerequisite.jl")

using PostgresORM, LibPQ

# Create the enum 'grievance_type' first because we need to create the variables
dbconn = TRAQUERUtil.openDBConn()
try
    @info "
    # ######################################### #
    # Add column stay.patient_died_during_stay  #
    # ######################################### #"

    "ALTER TABLE stay ADD COLUMN IF NOT EXISTS patient_died_during_stay boolean DEFAULT false" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

catch e
    rethrow(e)
finally
    TRAQUERUtil.closeDBConn(dbconn)
end

@warn "
SUCCESS!
"

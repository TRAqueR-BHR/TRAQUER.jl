include("../../prerequisite.jl")

using PostgresORM, LibPQ

# Create the enum 'grievance_type' first because we need to create the variables
dbconn = TRAQUERUtil.openDBConn()
try
    @info "
    # ################# #
    # Create schema ETL #
    # ################# #"
    """
    CREATE SCHEMA IF NOT EXISTS ETL;
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    @info "
    # ############################### #
    # Create table etl.fhir_xml_error #
    # ############################### #"
    """
    CREATE TABLE IF NOT EXISTS ETL.fhir_xml_error (
        id uuid DEFAULT uuid_generate_v4() NOT NULL,
        file_name TEXT NOT NULL,
        line_number INT NOT NULL,
        error_message TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
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

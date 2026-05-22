include("../../prerequisite.jl")

using PostgresORM, LibPQ

dbconn = TRAQUERUtil.openDBConn()
try

    @info "
    # #################################### #
    # Drop table etl.stay_data_needed      #
    # #################################### #"
    """
    DROP TABLE IF EXISTS etl.stay_data_needed CASCADE;
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    @info "
    # ###################################### #
    # Create table etl.stay_extraction_scope #
    # ###################################### #"
    """
    CREATE TABLE IF NOT EXISTS etl.stay_extraction_scope (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
        justification TEXT,
        deactivation_condition TEXT,
        unit_ids TEXT,
        patient_ids TEXT,
        period_oi_start_time TIMESTAMPTZ,
        period_oi_end_time TIMESTAMPTZ,
        activation_time TIMESTAMPTZ,
        deactivation_time TIMESTAMPTZ
    );
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON TABLE etl.stay_extraction_scope IS
        'Registry of scopes of stay data that are needed to be extracted from the source system (the hospital information system).';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.justification IS
        'Justification of why this scope of stay data is needed. This is just a hint for the admins or the auditors.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.deactivation_condition IS
        'Condition under which this scope of stay data is no longer needed and therefore gets deactivated. Also see deactivation_time';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.unit_ids IS
        'Comma-separated list of unit IDs of interest';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.patient_ids IS
        'Comma-separated list of patient IDs of interest';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.period_oi_start_time IS
        'Start time of the period of interest (to be compared with stay.in_time)';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.period_oi_end_time IS
        'End time of the period of interest (to be compared with stay.in_time not out_time)';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.activation_time IS
        'Time when this scope of stay data was activated';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.deactivation_time IS
        'Time when this scope of stay data was deactivated (also see deactivation_condition)';
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

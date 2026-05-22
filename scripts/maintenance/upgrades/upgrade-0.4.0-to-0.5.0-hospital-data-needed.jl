include("../../prerequisite.jl")

using PostgresORM, LibPQ

dbconn = TRAQUERUtil.openDBConn()
try

    @info "
    # ################################# #
    # Create table etl.stay_data_needed #
    # ################################# #"
    """
    CREATE TABLE IF NOT EXISTS etl.stay_data_needed (
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
    COMMENT ON COLUMN etl.stay_data_needed.justification IS
        'Justification of why this scope of stay data is needed. This is just a hint for the admins or the auditors.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_data_needed.deactivation_condition IS
        'Condition under which this scope of stay data is no longer needed and therefore gets deactivated. Also see deactivation_time'
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_data_needed.unit_ids IS
        'Comma-separated list of unit IDs of interest';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_data_needed.patient_ids IS
        'Comma-separated list of patient IDs of interest';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_data_needed.period_oi_start_time IS
        'Start time of the period of interest (to be compared with stay.in_time)';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_data_needed.period_oi_end_time IS
        'End time of the period of interest (to be compared with stay.in_time not out_time)';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_data_needed.activation_time IS
        'Time when this scope of stay data was activated';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_data_needed.deactivation_time IS
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

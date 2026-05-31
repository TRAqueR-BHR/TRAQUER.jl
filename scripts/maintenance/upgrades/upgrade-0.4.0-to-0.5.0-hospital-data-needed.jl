include("../../prerequisite.jl")

using PostgresORM, LibPQ

dbconn = TRAQUERUtil.openDBConn()
try

    @info "
    # ###################################### #
    # Drop previous stay scope tables        #
    # ###################################### #"
    """
    DROP TABLE IF EXISTS etl.stay_data_needed CASCADE;
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    DROP TABLE IF EXISTS etl.stay_extraction_scope CASCADE;
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    DROP TABLE IF EXISTS etl.stay_monitoring_scope CASCADE;
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    @info "
    # ###################################### #
    # Create table etl.stay_monitoring_scope #
    # ###################################### #"
    """
    CREATE TABLE IF NOT EXISTS etl.stay_monitoring_scope (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
        monitored_unit_id UUID REFERENCES unit(id),
        monitored_patient_id UUID REFERENCES patient(id),
        justifying_infectious_status_id UUID REFERENCES infectious_status(id),
        justifying_outbreak_id UUID REFERENCES outbreak(id),
        justification_additional_info TEXT,
        period_oi_start_time TIMESTAMPTZ,
        period_oi_end_time TIMESTAMPTZ,
        activation_time TIMESTAMPTZ,
        deactivation_time TIMESTAMPTZ
    );
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    CREATE INDEX IF NOT EXISTS stay_monitoring_scope_monitored_unit_id_idx
        ON etl.stay_monitoring_scope(monitored_unit_id);
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    CREATE INDEX IF NOT EXISTS stay_monitoring_scope_monitored_patient_id_idx
        ON etl.stay_monitoring_scope(monitored_patient_id);
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    CREATE INDEX IF NOT EXISTS stay_monitoring_scope_justifying_infectious_status_id_idx
        ON etl.stay_monitoring_scope(justifying_infectious_status_id);
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    CREATE INDEX IF NOT EXISTS stay_monitoring_scope_justifying_outbreak_id_idx
        ON etl.stay_monitoring_scope(justifying_outbreak_id);
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON TABLE etl.stay_monitoring_scope IS
        'Registry of scopes of stay data that are monitored over time.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.monitored_unit_id IS
        'Unit whose stays are monitored by this scope, when the monitoring scope targets a unit';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.monitored_patient_id IS
        'Patient whose stays are monitored by this scope, when the monitoring scope targets a patient';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.justifying_infectious_status_id IS
        'Infectious status that justifies monitoring this scope, when applicable';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.justifying_outbreak_id IS
        'Outbreak that justifies monitoring this scope, when applicable';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.justification_additional_info IS
        'Additional information, if necessary, explaining why this scope of stay data is monitored. This is just a hint for the admins or the auditors.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.period_oi_start_time IS
        'Start time of the period of interest (to be compared with stay.in_time)';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.period_oi_end_time IS
        'End time of the period of interest (to be compared with stay.in_time not out_time)';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.activation_time IS
        'Time when this scope of stay data was activated';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_monitoring_scope.deactivation_time IS
        'Time when this scope of stay data was deactivated (also see deactivation_condition)';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    @info "
    # ###################################### #
    # Create table etl.stay_extraction_scope #
    # ###################################### #"
    """
    CREATE TABLE IF NOT EXISTS etl.stay_extraction_scope (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
        stay_monitoring_scope_id UUID NOT NULL REFERENCES etl.stay_monitoring_scope(id),
        request_time TIMESTAMPTZ
    );
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    CREATE INDEX IF NOT EXISTS stay_extraction_scope_stay_monitoring_scope_id_idx
        ON etl.stay_extraction_scope(stay_monitoring_scope_id);
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON TABLE etl.stay_extraction_scope IS
        'Registry of scopes of stay data that are requested from the source system (the hospital information system) at a given time.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.stay_monitoring_scope_id IS
        'Monitoring scope that caused this extraction scope to be requested';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.stay_extraction_scope.request_time IS
        'Time when this extraction scope was requested';
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

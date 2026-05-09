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
    # ################################### #
    # Create sequence etl.seq_kdf_child_key_ref #
    # ################################### #"
    """
    CREATE SEQUENCE IF NOT EXISTS etl.seq_kdf_child_key_ref
        AS INTEGER
        START WITH 1
        INCREMENT BY 1
        MINVALUE 1
        MAXVALUE 2147483647
        CYCLE;
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    @info "
    # ################################### #
    # Create table etl.kdf_child_key      #
    # ################################### #"
    """
    CREATE TABLE IF NOT EXISTS etl.kdf_child_key (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
        ref INTEGER NOT NULL,
        salt_value TEXT NOT NULL,
        digest VARCHAR(32) NOT NULL DEFAULT 'SHA256',
        key_length SMALLINT NOT NULL DEFAULT 32,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        expires_at TIMESTAMPTZ,

        CONSTRAINT uq_kdf_child_key_ref
            UNIQUE (ref)
    );
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON TABLE etl.kdf_child_key IS
        'Registry of child keys derivated from the unit master key and used for file encryption
        operations. Each child key has its own salt.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.kdf_child_key.ref IS
        'Child key reference stored in encrypted file metadata';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.kdf_child_key.salt_value IS
        'Salt value';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.kdf_child_key.digest IS
        'Digest algorithm used in the key derivation function (eg. SHA256).';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.kdf_child_key.key_length IS
        'Length of the derived key in bytes used in the key derivation function.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.kdf_child_key.created_at IS
        'Timestamp when the child key allocation entry was created.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    COMMENT ON COLUMN etl.kdf_child_key.expires_at IS
        'Timestamp after which the child key should no longer be used for new encryptions. Existing encrypted files remain decryptable.';
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    CREATE INDEX IF NOT EXISTS idx_kdf_child_key_ref
        ON etl.kdf_child_key (ref);
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    """
    CREATE INDEX IF NOT EXISTS idx_kdf_child_key_expires_at
        ON etl.kdf_child_key (expires_at);
    """ |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    @info "
    # ########################### #
    # Create type binary_encoding #
    # ########################### #"
    "DROP TYPE IF EXISTS public.binary_encoding" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)
    "CREATE TYPE binary_encoding AS ENUM (
        'hex', -- Hexadecimal encoding
        'base64' -- Base64 encoding
    );
    "  |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

catch e
    rethrow(e)
finally
    TRAQUERUtil.closeDBConn(dbconn)
end

@warn "
SUCCESS!
"

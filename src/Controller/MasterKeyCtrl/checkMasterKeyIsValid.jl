function MasterKeyCtrl.checkMasterKeyIsValid(
    masterKeyWords::Vector{String},
    dbconn::LibPQ.Connection
)::Bool

    masterKeyHex = MasterKeyCtrl.generateMasterKeyFromWords(masterKeyWords)

    try
        "
        SELECT
            p.id AS patient_id,
            pgp_sym_decrypt(pbc.birthdate_crypt, \$1) AS birth_date
        FROM patient p
        INNER JOIN patient_birthdate_crypt pbc
            ON  pbc.year = p.birth_year
            AND pbc.id = p.birthdate_crypt_id
        LIMIT 1" |>
        n -> PostgresORM.execute_plain_query(n, [masterKeyHex], dbconn)
        return true
    catch e
        return false
    end
end

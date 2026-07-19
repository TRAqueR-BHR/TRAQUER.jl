function KdfChildKeyCtrl.generateAndSerializeChildKey(
    infoPrefix::String,
    ttl::Period,
    dbconn::LibPQ.Connection,
)::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}}

    KdfChildKeyCtrl.generateAndSerializeChildKey(
        MasterKeyCtrl.getMasterKey(),
        infoPrefix,
        ttl,
        dbconn,
    )

end

function KdfChildKeyCtrl.generateAndSerializeChildKey(
    parentKeyHex::String,
    infoPrefix::String,
    ttl::Period,
    dbconn::LibPQ.Connection,
)::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}}

    # Each child key gets its own random salt. The salt is not secret; it is stored in the
    # kdf_child_key table so the same child key can be derived again later from the master key.
    saltHex = rand(UInt8, 16) |> TRAQUERUtil.bytesToHex

    # Allocate a stable child-key reference. This ref is returned to the caller and can be stored
    # in encrypted file metadata; it is then used to retrieve the KDF parameters from the database.
    queryStr = "SELECT NEXTVAL('crypt.seq_kdf_child_key_ref')"
    ref = PostgresORM.execute_plain_query(queryStr, missing, dbconn) |> n -> Int16(n[1, 1])

    # Build the info string
    info = KdfChildKeyCtrl._buildInfo(infoPrefix, ref)

    # Persist all non-secret HKDF parameters needed to rederive the child key in the future:
    # ref, salt, digest, key length, creation time, and expiration time. The parent/master key is
    # intentionally not stored here and must be supplied by the caller when deriving the key.
    _now = now(TRAQUERUtil.getTimeZone())
    kdfChildKey = Model.KdfChildKey(
        ref = ref,
        keyLength = KdfChildKeyCtrl._CHILD_KEY_LENGTH,
        digest = KdfChildKeyCtrl._CHILD_KEY_DIGEST,
        createdAt = _now,
        expiresAt = _now + ttl,
        saltValue = saltHex,
        info = info,
    )

    # The sequence should give us a fresh ref, but this upsert-like logic keeps the method
    # idempotent/safe if a row with the same ref already exists for any reason.
    existingKdfChildKey::Union{Missing,Model.KdfChildKey} = PostgresORM.retrieve_one_entity(
        Model.KdfChildKey(ref = kdfChildKey.ref),
        false,
        dbconn,
    )

    if ismissing(existingKdfChildKey)
        PostgresORM.create_entity!(kdfChildKey, dbconn)
    else
        kdfChildKey.id = existingKdfChildKey.id
        PostgresORM.update_entity!(kdfChildKey, dbconn)
    end

    # Derive the actual child key from the parent key and the serialized KDF parameters. Only the
    # encoded child key and the ref are returned; the database row contains enough public metadata
    # to derive the same child key again later.
    childKeyHex = KdfChildKeyCtrl.deriveEncodedChildKey(
        parentKeyHex,
        kdfChildKey.saltValue,
        info,
        BinaryEncoding.hex,
    )

    result = (ref = kdfChildKey.ref, childKeyHex = childKeyHex)

    return result

end

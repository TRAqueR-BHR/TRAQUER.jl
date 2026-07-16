function FileExchangeCtrl.decryptFileWithSidecar(
    filePath::String,
    sidecarFilePath::String,
    dbconn::LibPQ.Connection
)::String

    childKeyRef::String = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(sidecarFilePath)

    kdfChildKey::Union{Missing,Model.KdfChildKey} = PostgresORM.retrieve_one_entity(
        Model.KdfChildKey(ref = childKeyRef),
        false,
        dbconn,
    )
    if ismissing(kdfChildKey)
        error(
            "KdfChildKey not found for ref=$childKeyRef " *
            "(from sidecar file $sidecarFilePath).",
        )
    end

    # Derive the child key hex from the instance master key and the KDF parameters
    # stored in the database. This is the same key that was used to encrypt the
    # file on the client side.
    childKeyHex::String = KdfChildKeyCtrl.deriveEncodedChildKey(
        CacheCtrl.getInstanceMasterKey(),
        kdfChildKey.saltValue,
        kdfChildKey.info,
    )

    # The parser returns the ref as an Int (it is also used as a database
    # key in other callers). The gpg passphrase here is the same ref
    # serialized as a string.
    return FileExchangeCtrl.decryptFile(filePath; cryptPwd = childKeyHex)

end

function FileExchangeCtrl.decryptFileWithSidecar(
    filePath::String,
    sidecarFilePath::String,
    dbconn::LibPQ.Connection
)::String

    cryptPwd::Union{Missing,String} = MasterKeyCtrl.getMasterKey()

    if ismissing(cryptPwd)
        error("Instance master key not set")
    end

    childKeyRef::Int = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(sidecarFilePath)

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
        cryptPwd,
        kdfChildKey.saltValue,
        kdfChildKey.info,
    )


    return FileExchangeCtrl.decryptFile(filePath; cryptPwd = childKeyHex)

end

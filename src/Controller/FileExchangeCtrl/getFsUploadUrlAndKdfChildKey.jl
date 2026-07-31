function FileExchangeCtrl.getFsUploadUrlAndKdfChildKey(
    _filename::String,
)::NamedTuple{
    (:ref, :childKeyHex, :fsUploadUrl, :instructions),
    Tuple{Int16, String, String, Vector{String}}
}

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        FileExchangeCtrl.getFsUploadUrlAndKdfChildKey(dbconn)
    end

end

function FileExchangeCtrl.getFsUploadUrlAndKdfChildKey(
    _filename::String,
    dbconn::LibPQ.Connection,
)::NamedTuple{
    (:ref, :childKeyHex, :fsUploadUrl, :instructions),
    Tuple{Int16, String, String, Vector{String}}
}

    # In case the filename is a path, extract the basename of the file
    _filename = basename(_filename)

    childKeyRefAndHex::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}} =
        FileExchangeCtrl.getKdfChildKey(dbconn)

    fsUploadUrl = joinpath(
        Conf.getFSPendingInputFilesDir(),
        _filename,
    )

    instructions = [
        "1. Encrypt the file with gpg using the derived child key (hex-encoded) as the " *
        "passphrase.",
        "2. Create a sidecar file containing the child key reference (key_ref) and " *
        "corresponding extractionScopesIds related to this file ",
        "3. Upload the encrypted file and its sidecar file to the provided file system URI ",
        "4. Notify TRAQUER that the file has been uploaded and is ready for processing"
    ]

    return (
        ref = childKeyRefAndHex.ref,
        childKeyHex = childKeyRefAndHex.childKeyHex,
        fsUploadUrl = fsUploadUrl,
        instructions = instructions,
    )

end

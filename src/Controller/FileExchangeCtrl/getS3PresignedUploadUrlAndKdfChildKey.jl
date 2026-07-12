function FileExchangeCtrl.getS3PresignedUploadUrlAndKdfChildKey(
    _filename::String,
)::NamedTuple{
    (:ref, :childKeyHex, :s3PresignedUploadUrl, :instructions),
    Tuple{Int16, String, String, Vector{String}}
}

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        FileExchangeCtrl.getS3PresignedUploadUrlAndKdfChildKey(dbconn)
    end

end

function FileExchangeCtrl.getS3PresignedUploadUrlAndKdfChildKey(
    _filename::String,
    dbconn::LibPQ.Connection,
)::NamedTuple{
    (:ref, :childKeyHex, :s3PresignedUploadUrl, :instructions),
    Tuple{Int16, String, String, Vector{String}}
}

    # In case the filename is a path, extract the basename of the file
    _filename = basename(_filename)

    childKeyRefAndHex::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}} =
        FileExchangeCtrl.getKdfChildKey(dbconn)

    s3ObjectKey = joinpath(
        Conf.getS3PendingInputFilesDir(),
        _filename,
    )

    s3PresignedUploadUrl = S3Ctrl.generatePresignedUploadUrl(
        TRAQUERUtil.Conf.getS3HospitalBucket(),
        s3ObjectKey,
    )

    instructions = [
        "1. Encrypt the file with gpg using the derived child key (hex-encoded) as the " *
        "passphrase.",
        "2. Create a sidecar file containing the child key reference (ref)",
        "3. Upload the encrypted file and its sidecar file to the provided S3 presigned " *
        "upload URL",
        "4. Notify TRAQUER that the file has been uploaded and is ready for processing"
    ]

    return (
        ref = childKeyRefAndHex.ref,
        childKeyHex = childKeyRefAndHex.childKeyHex,
        s3PresignedUploadUrl = s3PresignedUploadUrl,
        instructions = instructions,
    )

end

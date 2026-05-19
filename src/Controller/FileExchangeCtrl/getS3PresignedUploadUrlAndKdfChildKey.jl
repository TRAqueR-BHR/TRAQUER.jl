function FileExchangeCtrl.getS3PresignedUploadUrlAndKdfChildKey()::NamedTuple{
    (:ref, :childKeyHex, :s3PresignedUploadUrl, :instructions),
    Tuple{Int16, String, String, Vector{String}}
}

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        childKeyRefAndHex::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}} =
            FileExchangeCtrl.getKdfChildKey(dbconn)

        s3ObjectKey = "file-exchange/$(childKeyRefAndHex.ref)-$(uuid4())"
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
        ]

        return (
            ref = childKeyRefAndHex.ref,
            childKeyHex = childKeyRefAndHex.childKeyHex,
            s3PresignedUploadUrl = s3PresignedUploadUrl,
            instructions = instructions,
        )
    end
end

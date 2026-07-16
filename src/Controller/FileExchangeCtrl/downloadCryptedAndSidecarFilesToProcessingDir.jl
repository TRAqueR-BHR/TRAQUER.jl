"""
    downloadCryptedAndSidecarFilesToProcessingDir(
        parsedFileURL::NamedTuple,
        processingSubDirPath::String,
    )::Tuple{String, String}

Download the crypted file and its sidecar file from the S3 processing
directory (where they were placed by
`moveCryptedAndSidecarFilesToProcessingDir`) into the local processing
directory `processingSubDirPath`.

This function only makes sense for `s3://` URLs. For `file://` URLs the
files are already at `processingSubDirPath` after
`moveCryptedAndSidecarFilesToProcessingDir`, so this function must not
be called - doing so raises an error.

Returns a tuple `(cryptedFilePath, sidecarFilePath)` pointing to the
local copies inside `processingSubDirPath`.
"""
function FileExchangeCtrl.downloadCryptedAndSidecarFilesToProcessingDir(
    parsedFileURL::NamedTuple,
    processingSubDirPath::String,
)::Tuple{String, String}

    if parsedFileURL.scheme !== :s3
        error(
            "downloadCryptedAndSidecarFilesToProcessingDir only supports " *
            "s3 URLs. For file:// URLs the files are already at " *
            "processingSubDirPath after moveCryptedAndSidecarFilesToProcessingDir.",
        )
    end

    cryptedBasename = basename(parsedFileURL.key)
    s3ProcessingSubDir = joinpath(
        TRAQUERUtil.Conf.getS3ProcessingInputFilesDir(),
        basename(processingSubDirPath),
    )

    cryptedFilePath = joinpath(processingSubDirPath, cryptedBasename)
    sidecarFilePath = joinpath(processingSubDirPath, "$(cryptedBasename).sidecar")

    s3CryptedKey = joinpath(s3ProcessingSubDir, cryptedBasename)
    s3SidecarKey = joinpath(s3ProcessingSubDir, "$(cryptedBasename).sidecar")

    S3Ctrl.download(parsedFileURL.bucket, s3CryptedKey, cryptedFilePath)
    S3Ctrl.download(parsedFileURL.bucket, s3SidecarKey, sidecarFilePath)

    return (cryptedFilePath, sidecarFilePath)

end

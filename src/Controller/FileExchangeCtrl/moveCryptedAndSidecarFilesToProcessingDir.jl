"""
    moveCryptedAndSidecarFilesToProcessingDir(
        fileURL::String,
        processingSubDirPath::String,
    )

Move the crypted file and its sidecar file to the processing directory.

For `s3://` URLs the files are copied from the S3 pending directory to the
S3 processing directory, under a sub-directory named after
`basename(processingSubDirPath)`. The original files in the pending
directory are left in place - cleanup of the pending directory is the
responsibility of a separate scheduled task.

For `file://` URLs the files are moved locally from their original
location to `processingSubDirPath`. The sidecar file (when present) is
moved alongside the crypted file.

`processingSubDirPath` is the local per-invocation processing directory.
It is only used:
- for `file://` URLs, as the destination of the local move;
- for `s3://` URLs, to derive the name of the per-invocation sub-directory
  created under the S3 processing directory.
"""
function FileExchangeCtrl.moveCryptedAndSidecarFilesToProcessingDir(
    fileURL::String,
    processingSubDirPath::String,
)

    parsedURL = FileExchangeCtrl.parseFileURL(fileURL)
    cryptedBasename = basename(fileURL)

    if parsedURL.scheme === :s3
        s3ProcessingSubDir = joinpath(
            TRAQUERUtil.Conf.getS3ProcessingInputFilesDir(),
            basename(processingSubDirPath),
        )
        s3CryptedKey = joinpath(s3ProcessingSubDir, cryptedBasename)
        s3SidecarKey = joinpath(s3ProcessingSubDir, "$(cryptedBasename).sidecar")

        # Stream the files through a local temp file to copy them from
        # the S3 pending directory to the S3 processing directory.
        tempCryptedPath = tempname()
        tempSidecarPath = tempname()
        try
            S3Ctrl.download(parsedURL.bucket, parsedURL.key, tempCryptedPath)
            S3Ctrl.upload(parsedURL.bucket, s3CryptedKey, tempCryptedPath)

            sidecarSourceKey = "$(parsedURL.key).sidecar"
            S3Ctrl.download(
                parsedURL.bucket, sidecarSourceKey, tempSidecarPath,
            )
            S3Ctrl.upload(parsedURL.bucket, s3SidecarKey, tempSidecarPath)
        finally
            rm(tempCryptedPath; force = true)
            rm(tempSidecarPath; force = true)
        end
    elseif parsedURL.scheme === :file
        if !isfile(parsedURL.localPath)
            error("File does not exist: $(parsedURL.localPath)")
        end
        localCryptedPath = joinpath(processingSubDirPath, cryptedBasename)
        mv(parsedURL.localPath, localCryptedPath; force = true)

        localSidecarSourcePath = "$(parsedURL.localPath).sidecar"
        if isfile(localSidecarSourcePath)
            localSidecarPath = joinpath(
                processingSubDirPath, "$(cryptedBasename).sidecar",
            )
            mv(localSidecarSourcePath, localSidecarPath; force = true)
        end
    else
        error("Unsupported scheme: $(parsedURL.scheme)")
    end

    return nothing

end

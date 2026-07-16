"""
    moveCryptedAndSidecarFilesToDoneDir(
        cryptedFilePath::String,
        sidecarFilePath::String,
        parsedFileURL::NamedTuple,
    )

Move the crypted file and (when present) its sidecar file to the
"done" directory once processing has succeeded.

For `s3://` URLs both files are uploaded to the S3 directory returned by
`TRAQUERUtil.Conf.getS3DoneInputFilesDir()` and the local copies are
deleted. For `file://` URLs both files are moved to the directory
returned by `TRAQUERUtil.Conf.getFSDoneInputFilesDir()`.
"""
function FileExchangeCtrl.moveCryptedAndSidecarFilesToDoneDir(
    cryptedFilePath::String,
    sidecarFilePath::String,
    parsedFileURL::NamedTuple,
)

    if parsedFileURL.scheme === :s3
        doneDir = TRAQUERUtil.Conf.getS3DoneInputFilesDir()
        doneKeyCrypted = joinpath(doneDir, basename(cryptedFilePath))
        S3Ctrl.upload(parsedFileURL.bucket, doneKeyCrypted, cryptedFilePath)
        if isfile(sidecarFilePath)
            doneKeySidecar = joinpath(doneDir, basename(sidecarFilePath))
            S3Ctrl.upload(parsedFileURL.bucket, doneKeySidecar, sidecarFilePath)
        end
        rm(cryptedFilePath; force = true)
        if isfile(sidecarFilePath)
            rm(sidecarFilePath; force = true)
        end
    elseif parsedFileURL.scheme === :file
        doneDir = TRAQUERUtil.Conf.getFSDoneInputFilesDir()
        mkpath(doneDir)
        destCrypted = joinpath(doneDir, basename(cryptedFilePath))
        mv(cryptedFilePath, destCrypted; force = true)
        if isfile(sidecarFilePath)
            destSidecar = joinpath(doneDir, basename(sidecarFilePath))
            mv(sidecarFilePath, destSidecar; force = true)
        end
    end

    return nothing

end

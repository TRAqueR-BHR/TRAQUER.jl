"""
    moveCryptedAndSidecarFilesToProblemsDir(
        cryptedFilePath::String,
        sidecarFilePath::String,
        parsedFileURL::NamedTuple,
    )

Move the crypted file and (when present) its sidecar file to the
"problems" directory after a processing error.

For `s3://` URLs both files are uploaded to the S3 directory returned by
`TRAQUERUtil.Conf.getS3InputFilesProblemsDir()` and the local copies
are deleted. For `file://` URLs both files are moved to the directory
returned by `TRAQUERUtil.Conf.getFSInputFilesProblemsDir()`.
"""
function FileExchangeCtrl.moveCryptedAndSidecarFilesToProblemsDir(
    cryptedFilePath::String,
    sidecarFilePath::String,
    parsedFileURL::NamedTuple,
)

    if parsedFileURL.scheme === :s3
        problemsDir = TRAQUERUtil.Conf.getS3InputFilesProblemsDir()
        problemsKeyCrypted = joinpath(problemsDir, basename(cryptedFilePath))
        S3Ctrl.upload(parsedFileURL.bucket, problemsKeyCrypted, cryptedFilePath)
        if isfile(sidecarFilePath)
            problemsKeySidecar = joinpath(
                problemsDir, basename(sidecarFilePath),
            )
            S3Ctrl.upload(parsedFileURL.bucket, problemsKeySidecar, sidecarFilePath)
        end
        rm(cryptedFilePath; force = true)
        if isfile(sidecarFilePath)
            rm(sidecarFilePath; force = true)
        end
    elseif parsedFileURL.scheme === :file
        problemsDir = TRAQUERUtil.Conf.getFSInputFilesProblemsDir()
        mkpath(problemsDir)
        destCrypted = joinpath(problemsDir, basename(cryptedFilePath))
        mv(cryptedFilePath, destCrypted; force = true)
        if isfile(sidecarFilePath)
            destSidecar = joinpath(problemsDir, basename(sidecarFilePath))
            mv(sidecarFilePath, destSidecar; force = true)
        end
    end

    return nothing

end

"""
    moveCryptedAndSidecarFilesToProblemsDir(
        cryptedFilePath::String,
        sidecarFilePath::String,
        parsedFileURL::NamedTuple,
        problemsSubDir::String,
    )

Move the crypted file and (when present) its sidecar file into the
per-file sub-directory `problemsSubDir` after a processing error.

`problemsSubDir` is expected to be returned by
`FileExchangeCtrl.createProblemsSubDirForXmlFile` (and therefore to
already exist on disk for `file://` URLs, or to be a valid S3 key
prefix for `s3://` URLs). For `file://` URLs the files are moved into
`problemsSubDir`; for `s3://` URLs they are uploaded under the
`problemsSubDir` key prefix and the local copies are deleted.
"""
function FileExchangeCtrl.moveCryptedAndSidecarFilesToProblemsDir(
    cryptedFilePath::String,
    sidecarFilePath::String,
    parsedFileURL::NamedTuple,
    problemsSubDir::String,
)

    if parsedFileURL.scheme === :s3
        problemsKeyCrypted = joinpath(problemsSubDir, basename(cryptedFilePath))
        S3Ctrl.upload(parsedFileURL.bucket, problemsKeyCrypted, cryptedFilePath)
        if isfile(sidecarFilePath)
            problemsKeySidecar = joinpath(
                problemsSubDir, basename(sidecarFilePath),
            )
            S3Ctrl.upload(parsedFileURL.bucket, problemsKeySidecar, sidecarFilePath)
        end
        rm(cryptedFilePath; force = true)
        if isfile(sidecarFilePath)
            rm(sidecarFilePath; force = true)
        end
    elseif parsedFileURL.scheme === :file
        destCrypted = joinpath(problemsSubDir, basename(cryptedFilePath))
        mv(cryptedFilePath, destCrypted; force = true)
        if isfile(sidecarFilePath)
            destSidecar = joinpath(problemsSubDir, basename(sidecarFilePath))
            mv(sidecarFilePath, destSidecar; force = true)
        end
    end

    return nothing

end

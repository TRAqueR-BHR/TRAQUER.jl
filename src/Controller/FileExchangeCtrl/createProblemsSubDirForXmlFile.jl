"""
    createProblemsSubDirForXmlFile(
        cryptedXmlFilePath::String,
        parsedFileURL::NamedTuple,
    )

Create (if it does not already exist) the per-file sub-directory
inside the configured "problems" directory dedicated to the XML file
being processed, and return its path.

The sub-directory name is derived from `basename(cryptedXmlFilePath)`
with any trailing `.gpg` stripped, so the folder name matches the
underlying XML (e.g. `demo-fhir SALIOU.xml.gpg` →
`demo-fhir SALIOU.xml`).

For `file://` URLs the destination is created under
`TRAQUERUtil.Conf.getFSInputFilesProblemsDir()` using `mkpath`, so the
returned path exists on disk by the time it is returned. For `s3://`
URLs the returned value is an S3 key prefix that does not need to be
explicitly created — S3 has no real concept of folders — and no
filesystem `mkpath` is performed.

The returned path is the destination used by
`FileExchangeCtrl.moveCryptedAndSidecarFilesToProblemsDir` and the
serialization of per-row ETL errors. Calling this function is
idempotent: if the directory already exists it is left untouched.
"""
function FileExchangeCtrl.createProblemsSubDirForXmlFile(
    cryptedXmlFilePath::String,
    parsedFileURL::NamedTuple,
)::String

    baseName = basename(cryptedXmlFilePath)
    if endswith(baseName, ".gpg")
        baseName = baseName[1:end - length(".gpg")]
    end

    problemsSubDir = if parsedFileURL.scheme === :s3
        joinpath(TRAQUERUtil.Conf.getS3InputFilesProblemsDir(), baseName)
    elseif parsedFileURL.scheme === :file
        joinpath(TRAQUERUtil.Conf.getFSInputFilesProblemsDir(), baseName)
    else
        error(
            "Unsupported fileURL scheme: $(parsedFileURL.scheme). " *
            "Expected 's3://' or 'file://'.",
        )
    end

    if parsedFileURL.scheme === :file
        mkpath(problemsSubDir)
    end

    return problemsSubDir

end

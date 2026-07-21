function ETLCtrl.serializeRowsInError(
    dfOfRowsInError::DataFrame,
    csvFilepath::String,
    problemsDir::String
)

    srcFileBasename = basename(csvFilepath)
    mkpath(problemsDir)
    filepathForLinesWithProblems = joinpath(problemsDir,"$(srcFileBasename)-lines-in-error.csv")
    filepathForErrorLog = joinpath(problemsDir,"$(srcFileBasename)-error.log")
    @info problemsDir

    # Initialize the file of the content in error with the header of the source CSV file
    contentInError = TRAQUERUtil.readLineXOfFile(csvFilepath, 1)

    # Initialize the error log
    errorLog = "This is the error log for file[$srcFileBasename]"

    for rowTmp in eachrow(dfOfRowsInError)
        lineNumInSrcFile = rowTmp.lineNumInSrcFile
        error = rowTmp.error

        lineContent = TRAQUERUtil.readLineXOfFile(csvFilepath, lineNumInSrcFile)

        contentInError *= "\n" * lineContent
        errorLog *= "\n\n" * lineContent
        errorLog *= "\n" * "Line number in src file[$lineNumInSrcFile]"
        errorLog *= "\n" * error

    end

    # Write to the files
    open(filepathForLinesWithProblems, "w") do file
        write(file, contentInError)
    end
    open(filepathForErrorLog, "w") do file
        write(file, errorLog)
    end

end

"""
    serializeRowsInError(
        dfOfRowsInError::DataFrame,
        outputPath::String,
    )

Write `dfOfRowsInError` to `outputPath`. The serialization scheme is
inferred from the prefix of `outputPath`:

- `s3://bucket/key` — the DataFrame is written to a temporary local
  file (via `CSV.write`) and uploaded to S3 with `S3Ctrl.upload`. The
  temporary file is always removed, even if the upload fails. The
  parent bucket/key must be valid; malformed URLs raise
  `ArgumentError`.
- `file:///abs/path` — the `file://` scheme is stripped and the
  DataFrame is written directly to the resulting local path. The
  parent directory is created with `mkpath` if needed.
- anything else — the value is treated as a local file path; the
  parent directory is created with `mkpath` if needed, and the
  DataFrame is written in place.

No source-file context is required — unlike the 3-argument overload
this method does not try to recompose the failing source rows.
"""
function ETLCtrl.serializeRowsInError(
    dfOfRowsInError::DataFrame,
    outputPath::String,
)
    if startswith(outputPath, "s3://")
        bucket, key = ETLCtrl._splitS3URLForSerializeRowsInError(outputPath)
        tmpPath = tempname()
        try
            CSV.write(tmpPath, dfOfRowsInError)
            S3Ctrl.upload(bucket, key, tmpPath)
        finally
            rm(tmpPath; force = true)
        end
    elseif startswith(outputPath, "file://")
        localPath = outputPath[length("file://") + 1:end]
        mkpath(dirname(localPath))
        CSV.write(localPath, dfOfRowsInError)
    else
        mkpath(dirname(outputPath))
        CSV.write(outputPath, dfOfRowsInError)
    end
    return nothing
end

# Internal helper: split an `s3://bucket/key` URL into `(bucket, key)`.
# Mirrors `FileExchangeCtrl.parseFileURL` for the s3 branch only,
# without pulling in a cross-controller dependency.
function ETLCtrl._splitS3URLForSerializeRowsInError(
    s3URL::String,
)::Tuple{String,String}
    withoutScheme = SubString(s3URL, length("s3://") + 1)
    slashIdx = findfirst('/', withoutScheme)
    if slashIdx === nothing
        throw(ArgumentError(
            "Invalid s3 URL (missing object key): $s3URL",
        ))
    end
    bucket = String(withoutScheme[1:slashIdx - 1])
    key = String(lstrip(withoutScheme[slashIdx + 1:end], '/'))
    if isempty(bucket)
        throw(ArgumentError(
            "Invalid s3 URL (empty bucket name): $s3URL",
        ))
    end
    return (bucket, key)
end

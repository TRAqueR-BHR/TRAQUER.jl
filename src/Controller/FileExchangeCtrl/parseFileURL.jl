"""
    parseFileURL(fileURL::String)

Parse a file URL and return a NamedTuple describing how to fetch it.

Supported schemes:
- `s3://bucket/object-key` → `scheme = :s3`, `bucket = "bucket"`,
  `key = "object-key"`, `localPath = ""`.
- `file:///absolute/path` (or `file://relative/path`) → `scheme = :file`,
  `bucket = ""`, `key = ""`, `localPath = "/absolute/path"`.

Any other scheme raises an `ArgumentError`. For `s3://` URLs that are
missing the object key (e.g. `s3://bucket`) or have an empty bucket
name (e.g. `s3:///key`) the function also raises an `ArgumentError`.
"""
function FileExchangeCtrl.parseFileURL(
    fileURL::String,
)::NamedTuple{(:scheme, :bucket, :key, :localPath), Tuple{Symbol, String, String, String}}

    if startswith(fileURL, "s3://")
        withoutScheme = SubString(fileURL, 6)
        slashIdx = findfirst('/', withoutScheme)
        if slashIdx === nothing
            throw(ArgumentError(
                "Invalid s3 URL (missing object key): $fileURL",
            ))
        end
        bucket = String(withoutScheme[1:slashIdx-1])
        key = String(lstrip(withoutScheme[slashIdx+1:end], '/'))
        if isempty(bucket)
            throw(ArgumentError(
                "Invalid s3 URL (empty bucket name): $fileURL",
            ))
        end
        return (
            scheme = :s3,
            bucket = bucket,
            key = key,
            localPath = "",
        )
    elseif startswith(fileURL, "file://")
        localPath = fileURL[8:end]
        return (
            scheme = :file,
            bucket = "",
            key = "",
            localPath = localPath,
        )
    else
        throw(ArgumentError(
            "Unsupported fileURL scheme: $fileURL. " *
            "Expected 's3://' or 'file://'.",
        ))
    end

end

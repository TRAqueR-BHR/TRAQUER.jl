import AWS
import Dates
import HTTP
import SHA

function Controller.S3Ctrl.generatePresignedUploadUrl(
    bucket::String,
    key::String;
    expiresInSeconds::Integer = 3600,
)::String

    if expiresInSeconds < 1 || expiresInSeconds > 604800
        throw(ArgumentError("expiresInSeconds must be between 1 and 604800 seconds"))
    end

    escapePath(path::AbstractString) = split(path, '/'; keepempty = true) .|>
        HTTP.escapeuri |>
        segments -> join(segments, "/")

    hmacSHA256(keyBytes::Vector{UInt8}, message::AbstractString)::Vector{UInt8} =
        SHA.hmac_sha256(keyBytes, message)

    config = Controller.S3Ctrl._getS3Config()
    credentials = AWS.check_credentials(AWS.credentials(config))

    time = Dates.now(Dates.UTC)
    date = Dates.format(time, Dates.DateFormat("yyyymmdd"))
    datetime = Dates.format(time, Dates.DateFormat("yyyymmdd\\THHMMSS\\Z"))

    scope = "$(date)/$(AWS.region(config))/s3/aws4_request"
    signedHeaders = "host"
    resource = "/$(HTTP.escapeuri(bucket))/$(escapePath(lstrip(key, '/')))"
    url = AWS.generate_service_url(config, "s3", resource)
    host = HTTP.URI(url).host

    queryParams = Pair{String,String}[
        "X-Amz-Algorithm" => "AWS4-HMAC-SHA256",
        "X-Amz-Credential" => "$(credentials.access_key_id)/$(scope)",
        "X-Amz-Date" => datetime,
        "X-Amz-Expires" => string(expiresInSeconds),
        "X-Amz-SignedHeaders" => signedHeaders,
    ]

    if !isempty(credentials.token)
        push!(queryParams, "X-Amz-Security-Token" => credentials.token)
    end

    canonicalQueryString = HTTP.escapeuri(sort!(queryParams))
    canonicalHeaders = "host:$(host)\n"
    payloadHash = "UNSIGNED-PAYLOAD"

    canonicalRequest = join(
        [
            "PUT",
            resource,
            canonicalQueryString,
            canonicalHeaders,
            signedHeaders,
            payloadHash,
        ],
        "\n",
    )

    canonicalRequestHash = bytes2hex(SHA.sha256(canonicalRequest))
    stringToSign = join(
        [
            "AWS4-HMAC-SHA256",
            datetime,
            scope,
            canonicalRequestHash,
        ],
        "\n",
    )

    signingKey = Vector{UInt8}("AWS4$(credentials.secret_key)")
    for scopePart in (date, AWS.region(config), "s3", "aws4_request")
        signingKey = hmacSHA256(signingKey, scopePart)
    end

    signature = bytes2hex(hmacSHA256(signingKey, stringToSign))

    return "$(url)?$(canonicalQueryString)&X-Amz-Signature=$(signature)"
end

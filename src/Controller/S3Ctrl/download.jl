function S3Ctrl.download(bucket::String, key::String, destPath::String)::String
    destDir = dirname(destPath)
    if !isempty(destDir) && destDir != "."
        mkpath(destDir)
    end

    resource = "/$(bucket)/$(lstrip(key, '/'))"

    open(destPath, "w") do io
        AWS.AWSServices.s3(
            "GET",
            resource,
            Dict{String,Any}("response_stream" => io);
            aws_config = S3Ctrl._getS3Config(),
        )
    end

    return destPath
end

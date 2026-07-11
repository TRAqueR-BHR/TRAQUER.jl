function S3Ctrl.upload(bucket::String, key::String, srcPath::String)::String
    objectKey = lstrip(key, '/')
    resource = "/$(bucket)/$(objectKey)"

    AWS.AWSServices.s3(
        "PUT",
        resource,
        Dict{String,Any}("body" => read(srcPath));
        aws_config = S3Ctrl._getS3Config(),
    )

    return objectKey
end

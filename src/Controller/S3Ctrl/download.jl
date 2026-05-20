import AWS

struct TRAQUERS3Config <: AWS.AbstractAWSConfig
    endpoint::String
    region::String
    credentials::AWS.AWSCredentials
    max_attempts::Int
end

AWS.region(config::TRAQUERS3Config) = config.region
AWS.credentials(config::TRAQUERS3Config) = config.credentials
AWS.max_attempts(config::TRAQUERS3Config) = config.max_attempts

function AWS.generate_service_url(config::TRAQUERS3Config, service::String, resource::String)
    service == "s3" || throw(ArgumentError("TRAQUERS3Config only supports S3 requests"))
    return string(rstrip(config.endpoint, '/'), resource)
end

function Controller.S3Ctrl._getS3Config()::TRAQUERS3Config
    credentials = AWS.AWSCredentials(
        TRAQUERUtil.Conf.getS3AccessKey(),
        TRAQUERUtil.Conf.getS3SecretKey(),
    )

    return TRAQUERS3Config(
        TRAQUERUtil.Conf.getS3Url(),
        TRAQUERUtil.Conf.getS3Region(),
        credentials,
        AWS.AWS_MAX_RETRY_ATTEMPTS,
    )
end

function Controller.S3Ctrl.download(bucket::String, key::String, destPath::String)::String
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
            aws_config = Controller.S3Ctrl._getS3Config(),
        )
    end

    return destPath
end

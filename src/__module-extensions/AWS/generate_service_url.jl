function AWS.generate_service_url(config::TRAQUERS3Config, service::String, resource::String)
    service == "s3" || throw(ArgumentError("TRAQUERS3Config only supports S3 requests"))
    return string(rstrip(config.endpoint, '/'), resource)
end

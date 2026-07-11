function S3Ctrl._getS3Config()::TRAQUERS3Config
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

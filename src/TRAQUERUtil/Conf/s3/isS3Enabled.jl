function Conf.isS3Enabled()::Bool
    if !Conf.hasConf("s3", "enabled")
        return false
    end
    return Conf.getConf("s3", "enabled") == "true"
end

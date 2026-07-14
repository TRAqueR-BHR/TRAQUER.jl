function Conf.slackIsConfigured()
    return Conf.hasConf("slack", "token")
end
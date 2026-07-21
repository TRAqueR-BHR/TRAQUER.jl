"""
    getRedisHost()

Returns the Redis host defined in the application configuration.
"""
function Conf.getRedisHost()
    return Conf.getConf("redis", "host")
end

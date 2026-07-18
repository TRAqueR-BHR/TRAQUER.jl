"""
    getRedisPassword()

Returns the Redis password defined in the application configuration.
"""
function Conf.getRedisPassword()
    return Conf.getConf("redis", "password")
end

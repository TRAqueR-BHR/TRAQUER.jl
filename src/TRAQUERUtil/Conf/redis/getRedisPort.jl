"""
    getRedisPort()

Returns the Redis port defined in the application configuration.
"""
function Conf.getRedisPort()

    port = Conf.getConf("redis", "port")

    # Ensure integer conversion if needed
    return parse(Int, port)
end

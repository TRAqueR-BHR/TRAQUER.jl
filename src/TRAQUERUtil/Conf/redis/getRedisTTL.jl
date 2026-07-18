"""
    getRedisTTL()

Returns the Redis TTL (Time To Live) defined in the application configuration.
"""
function Conf.getRedisTTL()

    ttl = Conf.getConf("redis", "ttl")

    # Ensure integer conversion if needed
    return parse(Int, ttl)
end

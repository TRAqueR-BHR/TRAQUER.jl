"""
    get(key::String)::String
Retrieve a value from the cache based on the provided key.
"""
function CacheCtrl.get(key::String)::Union{String, Missing}

    # Temporary implementation for testing purposes, it should actually retrieve the value
    # from redis
    # return bytes2hex(SHA.sha256("cat boat rain"))

    redisConn = CacheCtrl._newRedisConnection()
    val = Redis.get(redisConn, key)

    # Refresh Redis value(s) if present
    if val !== nothing

        ttl::Int = Conf.getRedisTTL()
        Redis.setex(redisConn, key, ttl, val)

        return val
    end

    return missing

end

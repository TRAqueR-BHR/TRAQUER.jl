"""
    getRedisConnection()

Lazy Redis connection. Not robust enough

WARNING: TRAQUER.redisConn -> not thread-safe
"""
function CacheCtrl._getRedisConnection()
    # global TRAQUER.redisConn
    if TRAQUER.redisConn === nothing
        TRAQUER.redisConn = CacheCtrl._newRedisConnection()
    end
    return TRAQUER.redisConn
end

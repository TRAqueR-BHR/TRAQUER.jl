function CacheCtrl.set(key::String, value::String)
    redisConn = CacheCtrl._getRedisConnection()
    ttl::Int = Conf.getRedisTTL()
    Redis.setex(redisConn, key, ttl, value)
end

function CacheCtrl.set(key::String, value::String)
    redisConn = CacheCtrl._newRedisConnection()
    ttl::Int = Conf.getRedisTTL()
    Redis.setex(redisConn, key, ttl, value)
end

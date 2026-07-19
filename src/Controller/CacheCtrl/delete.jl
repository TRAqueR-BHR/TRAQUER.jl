function CacheCtrl.delete(key::String)
    redisConn = CacheCtrl._newRedisConnection()
    @info "Deleting key from cache: $key"
    Redis.del(redisConn, key)
end

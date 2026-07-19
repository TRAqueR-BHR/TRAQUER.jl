function CacheCtrl._newRedisConnection()
    host     = Conf.getRedisHost()
    port     = Conf.getRedisPort()
    password = Conf.getRedisPassword()

    return Redis.RedisConnection(host=host, port=port, password=password)
end

include("__prerequisite.jl")

@testset "Test CacheCtrl._newRedisConnection builds a RedisConnection with config values" begin

    conn = CacheCtrl._newRedisConnection()

    # The connection should use the values from the real config
    @test conn.host == Conf.getRedisHost()
    @test conn.port == Conf.getRedisPort()
    @test conn.password == Conf.getRedisPassword()

    # Should be a valid Redis.RedisConnection
    @test conn isa Redis.RedisConnection
end

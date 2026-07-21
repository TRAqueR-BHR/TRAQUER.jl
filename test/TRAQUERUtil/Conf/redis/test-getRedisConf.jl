include("__prerequisite.jl")

@testset "Test Conf Redis accessors" begin
    # Values from the real config file loaded in the test environment:
    # [redis]
    # host=traquer-redis
    # password=wewjqx$lom45rlom
    # port=6379
    # ttl=3000

    # getRedisHost
    @test Conf.getRedisHost() == "traquer-redis"
    @test Conf.getRedisHost() isa String

    # getRedisPassword
    @test Conf.getRedisPassword() == "wewjqx\$lom45rlom"
    @test Conf.getRedisPassword() isa String

    # getRedisPort - parses the string value to Int
    @test Conf.getRedisPort() == 6379
    @test Conf.getRedisPort() isa Int

    # getRedisTTL - parses the string value to Int
    @test Conf.getRedisTTL() == 3000
    @test Conf.getRedisTTL() isa Int
end

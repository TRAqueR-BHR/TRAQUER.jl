include("__prerequisite.jl")

@testset "Test CacheCtrl.set stores a value with the configured TTL" begin

    # Use the real Redis infrastructure (connection from config)
    conn = CacheCtrl._newRedisConnection()

    test_key = "test-traquer-set-$(uuid4())"
    test_value = "test-value-$(uuid4())"

    # Store the value
    CacheCtrl.set(test_key, test_value)

    # Verify it was stored by retrieving it via Redis.get
    retrieved = Redis.get(conn, test_key)

    @test retrieved == test_value

    # Clean up
    Redis.del(conn, test_key)

end

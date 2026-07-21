include("__prerequisite.jl")

@testset "Test MasterKeyCtrl.setMasterKey" begin

    # Save the original master key so we can restore it
    originalKey = CacheCtrl.getInstanceMasterKey()

    try
        # Test with invalid/arbitrary words - should return false
        invalidWords = ["invalid", "wrong", "key", "words"]
        result = MasterKeyCtrl.setMasterKey(invalidWords)
        @test result == false


        # Test with the default encryption key used in tests
        # This should succeed and store the key in cache
        defaultWords = _TestUtils.getDefaultMasterKeyWords()
        validResult = MasterKeyCtrl.setMasterKey(defaultWords)
        @test validResult == true

        # Verify the key was stored in cache
        cachedKey = CacheCtrl.getInstanceMasterKey()
        expectedHex = MasterKeyCtrl.generateMasterKeyFromWords(defaultWords)
        @test cachedKey == expectedHex

    finally
        # Restore the original master key (or clear if there was none)
        if ismissing(originalKey)
            redisConn = CacheCtrl._newRedisConnection()
            Redis.del(redisConn, "master_key")
        else
            CacheCtrl.set("master_key", originalKey)
        end
    end

end

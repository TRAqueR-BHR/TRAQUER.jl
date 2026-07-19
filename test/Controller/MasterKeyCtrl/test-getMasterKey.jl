include("__prerequisite.jl")

@testset "Test MasterKeyCtrl.getMasterKey" begin

    # Save the original master key so we can restore it
    originalKey = CacheCtrl.getInstanceMasterKey()

    try
        # Clear any existing key to test the empty/missing case
        CacheCtrl.set("master_key", "")

        # Test that getMasterKey returns empty string when no key is set
        retrievedEmpty = MasterKeyCtrl.getMasterKey()
        @test retrievedEmpty == ""

        # Set a valid key (with valid words) if schema exists, otherwise test with any key
        schemaExists = try
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                checkResult = PostgresORM.execute_plain_query(
                    "SELECT 1 FROM pg_tables WHERE schemaname = 'patient' AND tablename = 'patient' LIMIT 1",
                    [],
                    dbconn
                )
                nrow(checkResult) > 0
            end
        catch
            false
        end

        if schemaExists
            # Test roundtrip: setMasterKey -> getMasterKey
            testWords = ["cat", "boat", "rain", "mill", "tree"]
            setResult = MasterKeyCtrl.setMasterKey(testWords)
            @test setResult == true

            # Verify the key was stored and can be retrieved
            retrieved = MasterKeyCtrl.getMasterKey()
            expectedHex = MasterKeyCtrl.generateMasterKeyFromWords(testWords)
            @test retrieved == expectedHex
        else
            # Without schema, just test that getMasterKey returns the cached value
            testWords = ["test", "words", "only"]
            testHex = MasterKeyCtrl.generateMasterKeyFromWords(testWords)
            CacheCtrl.setInstanceMasterKey(testHex)

            retrieved = MasterKeyCtrl.getMasterKey()
            @test retrieved == testHex
        end
    finally
        # Restore the original master key (or clear if there was none)
        if ismissing(originalKey) || isempty(originalKey)
            CacheCtrl.set("master_key", "")
        else
            CacheCtrl.set("master_key", originalKey)
        end
    end

end

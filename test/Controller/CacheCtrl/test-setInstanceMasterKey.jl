include("__prerequisite.jl")

@testset "Test CacheCtrl.setInstanceMasterKey stores hex string in cache" begin

    # Store the original master key so we can restore it
    originalKey = CacheCtrl.getInstanceMasterKey()

    # Test hex string
    testHex = TRAQUERUtil.stringToHex("traquer test unit 2024")

    # Set the master key directly with hex
    CacheCtrl.setInstanceMasterKey(testHex)

    # Verify by retrieving
    retrieved = CacheCtrl.getInstanceMasterKey()
    @test retrieved == testHex

    # Restore the original value (or clear if there was none)
    if ismissing(originalKey)
        CacheCtrl.set("master_key", "")
    else
        CacheCtrl.set("master_key", originalKey)
    end

end

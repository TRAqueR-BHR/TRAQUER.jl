include("__prerequisite.jl")

@testset "Test MasterKeyCtrl.generateMasterKeyFromWords" begin

    # Test basic conversion
    words = ["cat", "boat", "rain"]
    expectedHex = TRAQUERUtil.stringToHex(join(words, " "))
    @test MasterKeyCtrl.generateMasterKeyFromWords(words) == expectedHex

    # Test single word
    singleWord = ["secret"]
    expectedSingleHex = TRAQUERUtil.stringToHex("secret")
    @test MasterKeyCtrl.generateMasterKeyFromWords(singleWord) == expectedSingleHex

    # Test empty vector
    emptyWords = String[]
    expectedEmptyHex = TRAQUERUtil.stringToHex("")
    @test MasterKeyCtrl.generateMasterKeyFromWords(emptyWords) == expectedEmptyHex

    # Test consistency with CacheCtrl.setInstanceMasterKey pattern
    testWords = ["traquer", "test", "unit", "2024"]
    masterKeyHex = MasterKeyCtrl.generateMasterKeyFromWords(testWords)
    # The hex should be usable as a key (non-empty, valid hex string)
    @test !isempty(masterKeyHex)
    @test all(c -> c in "0123456789abcdef", masterKeyHex)

end

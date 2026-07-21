include("__prerequisite.jl")

@testset "Test TRAQUERUtil encoding helpers" begin
    bytes = UInt8[0x48, 0x69]

    @test TRAQUERUtil.bytesToHex(bytes) == "4869"
    @test TRAQUERUtil.hexToBytes("48:69") == bytes

    @test TRAQUERUtil.bytesToBase64(bytes) == "SGk="
    @test TRAQUERUtil.base64ToBytes("SGk=") == bytes

    @test TRAQUERUtil.hexToBase64("4869") == "SGk="
    @test TRAQUERUtil.base64ToHex("SGk=") == "4869"

    @test TRAQUERUtil.stringToHex("Hé") == "48c3a9"
    @test TRAQUERUtil.hexToString("48c3a9") == "Hé"

    @test TRAQUERUtil.stringToBase64("Hé") == "SMOp"
    @test TRAQUERUtil.base64ToString("SMOp") == "Hé"

    # Test stringToSHA256
    # SHA256 of "hello" = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
    hello_sha256 = TRAQUERUtil.stringToSHA256("hello")
    @test length(hello_sha256) == 32  # SHA256 produces 32 bytes
    @test TRAQUERUtil.bytesToHex(hello_sha256) == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"

    # Test consistency
    @test TRAQUERUtil.stringToSHA256("test") == TRAQUERUtil.stringToSHA256("test")

    # Test different inputs produce different outputs
    @test TRAQUERUtil.stringToSHA256("hello") != TRAQUERUtil.stringToSHA256("world")

end

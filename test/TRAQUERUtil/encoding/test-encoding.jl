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
end

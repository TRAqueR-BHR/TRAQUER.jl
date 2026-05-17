include("__prerequisite.jl")

@testset "Test KdfChildKeyCtrl._buildInfo" begin
    ref = Int16(42)

    @test KdfChildKeyCtrl._buildInfo("file-exchange", ref) == "file-exchange[42]"
    @test KdfChildKeyCtrl._buildInfo("file-exchange/", ref) == "file-exchange/42"
    @test KdfChildKeyCtrl._buildInfo("file-exchange=", ref) == "file-exchange=42"
    @test KdfChildKeyCtrl._buildInfo("v1", ref) == "v1[42]"
end

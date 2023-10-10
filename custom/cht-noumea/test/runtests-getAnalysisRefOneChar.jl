include("prerequisite.jl")

@testset "Test Custom.getAnalysisRefOneChar" begin
    @test Custom.getAnalysisRefOneChar("800000000302_ATB2") == "3"
    @test Custom.getAnalysisRefOneChar("800000000302") == "3"
    @test Custom.getAnalysisRefOneChar("8000000003") == "3"
    @test Custom.getAnalysisRefOneChar("81234567") == "7"
end

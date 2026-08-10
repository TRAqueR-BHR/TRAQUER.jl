include("__prerequisite.jl")

@testset "Test _TestUtils.buildRandomPatientFirstname" begin
    firstnames = [_TestUtils.buildRandomPatientFirstname() for _ in 1:100]

    @test all(firstname -> firstname isa String, firstnames)
    @test all(firstname -> !isempty(strip(firstname)), firstnames)
end

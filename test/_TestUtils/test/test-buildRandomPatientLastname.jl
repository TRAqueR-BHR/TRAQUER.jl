include("__prerequisite.jl")

@testset "Test _TestUtils.buildRandomPatientLastname" begin
    lastnames = [_TestUtils.buildRandomPatientLastname() for _ in 1:100]

    @test all(lastname -> lastname isa String, lastnames)
    @test all(lastname -> !isempty(strip(lastname)), lastnames)
end

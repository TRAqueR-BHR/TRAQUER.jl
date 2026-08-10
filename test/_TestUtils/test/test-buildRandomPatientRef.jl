include("__prerequisite.jl")

@testset "Test _TestUtils.buildRandomPatientRef" begin
    refs = [_TestUtils.buildRandomPatientRef() for _ in 1:100]

    @test all(ref -> ref isa String, refs)
    @test all(ref -> length(ref) == 8, refs)
    @test all(ref -> occursin(r"^[A-Z]{4}[0-9]{4}$", ref), refs)
end

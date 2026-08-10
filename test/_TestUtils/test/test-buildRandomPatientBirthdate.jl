include("__prerequisite.jl")

@testset "Test _TestUtils.buildRandomPatientBirthdate" begin
    birthdates = [_TestUtils.buildRandomPatientBirthdate() for _ in 1:100]
    minBirthdate = today() - Year(110)
    maxBirthdate = today() - Year(1)

    @test all(birthdate -> birthdate isa Date, birthdates)
    @test all(birthdate -> minBirthdate <= birthdate <= maxBirthdate, birthdates)
end

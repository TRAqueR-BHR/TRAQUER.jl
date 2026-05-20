include("__prerequisite.jl")

@testset "Test Conf.hasConf" begin
    @test Conf.hasConf("default", "timezone")
    @test !Conf.hasConf("default", "__missing_property__")
    @test !Conf.hasConf("__missing_section__", "timezone")
end

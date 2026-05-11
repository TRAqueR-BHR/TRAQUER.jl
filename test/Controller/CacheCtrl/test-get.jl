include("__prerequisite.jl")

@testset "Test CacheCtrl.get" begin
    @test CacheCtrl.get("dummy-key") == "c727f04e543e8715ab72ba2f79c012cf4267c514d3f20cab73f816a562f175f0"
end

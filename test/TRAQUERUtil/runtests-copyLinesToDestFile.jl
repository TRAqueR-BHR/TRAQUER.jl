include("../runtests-prerequisite.jl")

@testset "Test TRAQUERUtil.copyLinesToDestFile" begin
    TRAQUERUtil.copyLinesToDestFile(
        "test/TRAQUERUtil/assets/testCopyLinesToDestFile.csv",
        [1,2],
        "tmp/outCopyLinesToDestFile.csv"
    )

end

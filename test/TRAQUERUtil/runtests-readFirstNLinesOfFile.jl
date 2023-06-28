include("../runtests-prerequisite.jl")

@testset "Test TRAQUERUtil.readFirstNLinesOfFile" begin
    TRAQUERUtil.readFirstNLinesOfFile(
        "/home/traquer/CODE/TRAQUER.jl/test/TRAQUERUtil/assets/testReadFirstLines.csv",
        2
    )
end

include("../runtests-prerequisite.jl")

@testset "Test TRAQUERUtil.readFirstNLinesOfCSVFile" begin
    TRAQUERUtil.readFirstNLinesOfCSVFile(
        "/home/traquer/CODE/TRAQUER.jl/test/TRAQUERUtil/assets/testReadFirstLines.csv",
        2
        ;delim = ";"
    )|> println
end

include("../runtests-prerequisite.jl")

@testset "Test TRAQUERUtil.readLineXOfFile" begin
    filename = "test/TRAQUERUtil/assets/test-readLineXOfFile.csv"
    @test TRAQUERUtil.readLineXOfFile(
        filename,
        2
    ) == "line2"
    @test_throws ErrorException TRAQUERUtil.readLineXOfFile(filename, 6)
end

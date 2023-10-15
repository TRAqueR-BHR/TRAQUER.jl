include("../runtests-prerequisite.jl")

@testset "Test ExposedFunctionCtrl.getJuliaFunction" begin

    TRAQUERUtil.getJuliaFunction("Custom.extractDailyActivityForPaperArchive")
    TRAQUERUtil.getJuliaFunction("TRAQUER.greet")

end

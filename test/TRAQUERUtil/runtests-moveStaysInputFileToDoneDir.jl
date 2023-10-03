include("prerequisite.jl")

@testset "Test moveStaysInputFileToDoneDir" begin

    filePath = touch("/tmp/test-$(now()).txt")
    @info filePath
    TRAQUERUtil.moveStaysInputFileToDoneDir(filePath)
end

include("__prerequisite.jl")

@testset "Test S3Ctrl.download" begin
    bucket = TRAQUERUtil.Conf.getS3HospitalBucket()
    key = "test.txt"

    mktempdir() do tempDir
        destPath = joinpath(tempDir, key)

        result = S3Ctrl.download(bucket, key, destPath)

        @test result == destPath
        @test isfile(destPath)
        @test filesize(destPath) > 0
        @info "Downloaded S3 file content" content = read(destPath, String)
    end
end

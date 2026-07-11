include("__prerequisite.jl")

@testset "Test S3Ctrl.upload" begin
    bucket = TRAQUERUtil.Conf.getS3HospitalBucket()
    key = "test-upload-$(uuid4()).txt"
    content = "Dummy S3 upload test file\n$(uuid4())\n"

    mktempdir() do tempDir
        srcPath = joinpath(tempDir, "source.txt")
        destPath = joinpath(tempDir, "downloaded.txt")
        write(srcPath, content)

        result = S3Ctrl.upload(bucket, key, srcPath)

        @test result == key

        S3Ctrl.download(bucket, key, destPath)

        @test isfile(destPath)
        @test read(destPath, String) == content
    end
end

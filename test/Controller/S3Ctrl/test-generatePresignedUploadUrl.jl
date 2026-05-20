include("__prerequisite.jl")

using HTTP

@testset "Test S3Ctrl.generatePresignedUploadUrl" begin
    # Use the configured hospital bucket and a unique key so this test can be
    # run repeatedly without colliding with previous uploads.
    bucket = TRAQUERUtil.Conf.getS3HospitalBucket()
    key = "test-presigned-upload-$(uuid4()).txt"
    expiresInSeconds = 600

    # This content is uploaded through the presigned URL, then downloaded back
    # through S3Ctrl.download to validate the complete upload/download flow.
    content = "Dummy S3 presigned upload test file\n$(uuid4())\n"

    # Generate a temporary PUT URL for this object.
    url = S3Ctrl.generatePresignedUploadUrl(
        bucket,
        key;
        expiresInSeconds = expiresInSeconds,
    )

    # First validate the shape of the generated SigV4 URL without logging the
    # full URL, because it contains credentials-derived signing material.
    uri = HTTP.URI(url)
    queryParams = HTTP.URIs.queryparams(uri.query)

    @test startswith(url, TRAQUERUtil.Conf.getS3Url())
    @test occursin("/$(bucket)/$(key)", url)
    @test queryParams["X-Amz-Algorithm"] == "AWS4-HMAC-SHA256"
    @test queryParams["X-Amz-Expires"] == string(expiresInSeconds)
    @test queryParams["X-Amz-SignedHeaders"] == "host"
    @test haskey(queryParams, "X-Amz-Credential")
    @test haskey(queryParams, "X-Amz-Date")
    @test haskey(queryParams, "X-Amz-Signature")
    @test !isempty(queryParams["X-Amz-Signature"])

    # Upload the dummy text content directly with the presigned URL. No AWS
    # credentials should be needed by the caller at this point.
    uploadResponse = HTTP.request(
        "PUT",
        url,
        Pair{String,String}[],
        content;
        status_exception = false,
    )

    @test uploadResponse.status in (200, 201)

    # Download the uploaded object with the controller helper and verify that
    # the content stored in S3 is exactly what was uploaded.
    mktempdir() do tempDir
        destPath = joinpath(tempDir, key)
        S3Ctrl.download(bucket, key, destPath)

        @test isfile(destPath)
        @test read(destPath, String) == content
    end
end

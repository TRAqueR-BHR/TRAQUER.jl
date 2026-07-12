include("__prerequisite.jl")

using HTTP

@testset "Test FileExchangeCtrl.getS3PresignedUploadUrlAndKdfChildKey" begin
    bucket = TRAQUERUtil.Conf.getS3HospitalBucket()
    content = "Dummy encrypted file-exchange payload\n$(uuid4())\n"

    result = TRAQUERUtil.createDBConnAndExecute() do dbconn
        FileExchangeCtrl.getS3PresignedUploadUrlAndKdfChildKey("dummy_filename.txt", dbconn)
    end

    @info result

    # Write the result to a json file for easier inspection of the test output.
    result |> JSON.json |>
        n -> open(
                joinpath(
                    "tmp",
                    "json",
                    "get_s3_presigned_upload_url_and_kdf_child_key_result.json"
                ),
                "w"
            ) do f
            write(f, n)
        end

    try
        @test result.ref isa Int16
        @test result.childKeyHex isa String
        @test length(result.childKeyHex) == 64
        @test result.s3PresignedUploadUrl isa String
        @test result.instructions isa Vector{String}
        @test length(result.instructions) == 3

        uri = HTTP.URI(result.s3PresignedUploadUrl)
        queryParams = HTTP.URIs.queryparams(uri.query)

        @test startswith(result.s3PresignedUploadUrl, TRAQUERUtil.Conf.getS3Url())
        @test startswith(uri.path, "/$(bucket)/file-exchange/$(result.ref)-")
        @test queryParams["X-Amz-Algorithm"] == "AWS4-HMAC-SHA256"
        @test haskey(queryParams, "X-Amz-Credential")
        @test haskey(queryParams, "X-Amz-Date")
        @test haskey(queryParams, "X-Amz-Signature")
        @test !isempty(queryParams["X-Amz-Signature"])

        TRAQUERUtil.createDBConnAndExecute() do dbconn
            persisted = PostgresORM.retrieve_one_entity(
                Model.KdfChildKey(ref = result.ref),
                false,
                dbconn,
            )

            @test !ismissing(persisted)
            @test persisted.ref == result.ref
            @test persisted.info == KdfChildKeyCtrl._buildInfo("file-exchange", result.ref)
            @test persisted.expiresAt == persisted.createdAt + Hour(24)
            @test result.childKeyHex == KdfChildKeyCtrl.deriveEncodedChildKey(
                CacheCtrl.getInstanceMasterKey(),
                persisted.saltValue,
                persisted.info,
                BinaryEncoding.hex,
            )
        end

        uploadResponse = HTTP.request(
            "PUT",
            result.s3PresignedUploadUrl,
            Pair{String,String}[],
            content;
            status_exception = false,
        )

        @test uploadResponse.status in (200, 201)

        objectKey = replace(uri.path, "/$(bucket)/" => ""; count = 1)
        mktempdir() do tempDir
            destPath = joinpath(tempDir, basename(objectKey))
            S3Ctrl.download(bucket, objectKey, destPath)

            @test isfile(destPath)
            @test read(destPath, String) == content
        end
    finally
        TRAQUERUtil.createDBConnAndExecute() do dbconn
            "DELETE FROM crypt.kdf_child_key WHERE ref = \$1" |>
            query -> PostgresORM.execute_plain_query(query, [result.ref], dbconn)
        end
    end
end

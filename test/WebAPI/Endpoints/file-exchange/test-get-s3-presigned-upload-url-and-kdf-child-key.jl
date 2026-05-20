include("__prerequisite.jl")

using HTTP

@testset "Test file-exchange get S3 presigned upload URL and KDF child key endpoint" begin
    ref = missing

    try
        req = Dict{Symbol,Any}(
            :method => "POST",
            :params => Dict{Symbol,Any}(:appuser => missing),
            :data => UInt8[],
        )

        response = TRAQUER.WebAPI.Endpoints.handle_file_exchange_get_s3_presigned_upload_url_and_kdf_child_key(req)

        @test response[:status] == 200
        @test response[:headers]["Content-Type"] == "application/json"

        result = JSON.parse(response[:body])
        ref = Int16(result["ref"])
        childKeyHex = result["childKeyHex"]
        s3PresignedUploadUrl = result["s3PresignedUploadUrl"]
        instructions = result["instructions"]

        @test ref isa Int16
        @test childKeyHex isa String
        @test length(childKeyHex) == 64
        @test s3PresignedUploadUrl isa String
        @test instructions isa Vector
        @test length(instructions) == 3

        uri = HTTP.URI(s3PresignedUploadUrl)
        queryParams = HTTP.URIs.queryparams(uri.query)
        bucket = TRAQUERUtil.Conf.getS3HospitalBucket()

        @test startswith(s3PresignedUploadUrl, TRAQUERUtil.Conf.getS3Url())
        @test startswith(uri.path, "/$(bucket)/file-exchange/$(ref)-")
        @test queryParams["X-Amz-Algorithm"] == "AWS4-HMAC-SHA256"
        @test haskey(queryParams, "X-Amz-Credential")
        @test haskey(queryParams, "X-Amz-Date")
        @test haskey(queryParams, "X-Amz-Signature")
        @test !isempty(queryParams["X-Amz-Signature"])

        TRAQUERUtil.createDBConnAndExecute() do dbconn
            persisted = PostgresORM.retrieve_one_entity(
                Model.KdfChildKey(ref = ref),
                false,
                dbconn,
            )

            @test !ismissing(persisted)
            @test persisted.ref == ref
            @test persisted.info == KdfChildKeyCtrl._buildInfo("file-exchange", ref)
            @test persisted.expiresAt == persisted.createdAt + Hour(24)
            @test childKeyHex == KdfChildKeyCtrl.deriveEncodedChildKey(
                CacheCtrl.getInstanceMasterKey(),
                persisted.saltValue,
                persisted.info,
                BinaryEncoding.hex,
            )
        end
    finally
        if !ismissing(ref)
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                "DELETE FROM crypt.kdf_child_key WHERE ref = \$1" |>
                query -> PostgresORM.execute_plain_query(query, [ref], dbconn)
            end
        end
    end
end

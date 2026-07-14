include("__prerequisite.jl")

@testset "Test file-exchange get KDF child key endpoint" begin
    ref = missing

    try
        req = Dict{Symbol,Any}(
            :method => "POST",
            :params => Dict{Symbol,Any}(:appuser => missing),
            :data => UInt8[],
        )

        response = WebAPI.Endpoints.handle_file_exchange_get_kdf_child_key(req)

        @test response[:status] == 200
        @test response[:headers]["Content-Type"] == "application/json"

        result = JSON.parse(response[:body])
        ref = Int16(result["ref"])
        childKeyHex = result["childKeyHex"]

        @test result isa Dict
        @test haskey(result, "ref")
        @test haskey(result, "childKeyHex")
        @test !haskey(result, "s3PresignedUploadUrl")
        @test !haskey(result, "instructions")
        @test ref isa Int16
        @test childKeyHex isa String
        @test length(childKeyHex) == 64

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

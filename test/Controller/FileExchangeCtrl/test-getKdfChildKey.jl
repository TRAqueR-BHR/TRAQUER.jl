include("__prerequisite.jl")

@testset "Test FileExchangeCtrl.getKdfChildKey" begin
    result = TRAQUERUtil.createDBConnAndExecute() do dbconn
        generated = FileExchangeCtrl.getKdfChildKey(dbconn)

        try
            persisted = PostgresORM.retrieve_one_entity(
                Model.KdfChildKey(ref = generated.ref),
                false,
                dbconn,
            )

            @test !ismissing(persisted)
            @test persisted.ref == generated.ref
            @test persisted.info == "file-exchange" * string(generated.ref)
            @test persisted.keyLength == KdfChildKeyCtrl._CHILD_KEY_LENGTH
            @test persisted.digest == KdfChildKeyCtrl._CHILD_KEY_DIGEST
            @test !ismissing(persisted.saltValue)
            @test length(persisted.saltValue) == 32
            @test persisted.expiresAt == persisted.createdAt + Hour(24)
            @test generated.childKeyHex == KdfChildKeyCtrl.deriveEncodedChildKey(
                CacheCtrl.getInstanceMasterKey(),
                persisted.saltValue,
                persisted.info,
                BinaryEncoding.hex,
            )

            return generated
        finally
            "DELETE FROM crypt.kdf_child_key WHERE ref = \$1" |>
            query -> PostgresORM.execute_plain_query(query, [generated.ref], dbconn)
        end
    end

    @test result.ref isa Int16
    @test result.childKeyHex isa String
    @test length(result.childKeyHex) == 64
end

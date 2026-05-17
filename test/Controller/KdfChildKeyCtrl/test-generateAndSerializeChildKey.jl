include("__prerequisite.jl")

@testset "Test KdfChildKeyCtrl.generateAndSerializeChildKey" begin
    parent_key_hex = "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff"
    info_prefix = "test/kdf-child-key/ref"
    ttl = Hour(1)

    result = TRAQUERUtil.createDBConnAndExecute() do dbconn
        generated = KdfChildKeyCtrl.generateAndSerializeChildKey(
            parent_key_hex,
            info_prefix,
            ttl,
            dbconn,
        )

        try
            persisted = PostgresORM.retrieve_one_entity(
                Model.KdfChildKey(ref = generated.ref),
                false,
                dbconn,
            )

            @test !ismissing(persisted)
            @test persisted.ref == generated.ref

            return generated
        finally
            "DELETE FROM crypt.kdf_child_key WHERE ref = \$1" |>
            query -> PostgresORM.execute_plain_query(query, [generated.ref], dbconn)
        end
    end

    @test result.ref isa Int16
    @test result.childKeyHex isa String
end

@testset "Test KdfChildKeyCtrl.generateAndSerializeChildKey with cached master key" begin
    info_prefix = "test/kdf-child-key/cached-master-key/ref="
    ttl = Hour(1)

    result = TRAQUERUtil.createDBConnAndExecute() do dbconn
        generated = KdfChildKeyCtrl.generateAndSerializeChildKey(
            info_prefix,
            ttl,
            dbconn,
        )

        try
            persisted = PostgresORM.retrieve_one_entity(
                Model.KdfChildKey(ref = generated.ref),
                false,
                dbconn,
            )

            @test !ismissing(persisted)
            @test persisted.info == info_prefix * string(generated.ref)

            expected_child_key_hex = KdfChildKeyCtrl.deriveEncodedChildKey(
                CacheCtrl.getInstanceMasterKey(),
                persisted.saltValue,
                persisted.info,
                BinaryEncoding.hex,
            )

            @test generated.childKeyHex == expected_child_key_hex

            return generated
        finally
            "DELETE FROM crypt.kdf_child_key WHERE ref = \$1" |>
            query -> PostgresORM.execute_plain_query(query, [generated.ref], dbconn)
        end
    end

    @test result.ref isa Int16
    @test result.childKeyHex isa String
end

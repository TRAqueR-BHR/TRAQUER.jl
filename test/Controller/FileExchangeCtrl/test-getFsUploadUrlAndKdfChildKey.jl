include("__prerequisite.jl")

using HTTP

@testset "Test FileExchangeCtrl.getFsUploadUrlAndKdfChildKey" begin
    bucket = TRAQUERUtil.Conf.getS3HospitalBucket()
    content = "Dummy encrypted file-exchange payload\n$(uuid4())\n"

    result = TRAQUERUtil.createDBConnAndExecute() do dbconn
        FileExchangeCtrl.getFsUploadUrlAndKdfChildKey("dummy_filename.txt", dbconn)
    end

    @info result

    # Write the result to a json file for easier inspection of the test output.
    result |> JSON.json |>
        n -> open(
                joinpath(
                    "tmp",
                    "json",
                    "get_fs_presigned_upload_url_and_kdf_child_key_result.json"
                ),
                "w"
            ) do f
            write(f, n)
        end

    try
        @test result.ref isa Int16
        @test result.childKeyHex isa String
        @test length(result.childKeyHex) == 64
       
    finally
        TRAQUERUtil.createDBConnAndExecute() do dbconn
            "DELETE FROM crypt.kdf_child_key WHERE ref = \$1" |>
            query -> PostgresORM.execute_plain_query(query, [result.ref], dbconn)
        end
    end
end

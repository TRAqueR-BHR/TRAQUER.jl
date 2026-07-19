include("__prerequisite.jl")

@testset "Test master-key set endpoint" begin
    # Save original key to restore later
    originalKey = CacheCtrl.getInstanceMasterKey()

    try
        # Clear the cache for test
        CacheCtrl.set("master_key", "")

        # Check if patient schema exists
        schemaExists = try
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                checkResult = PostgresORM.execute_plain_query(
                    "SELECT 1 FROM pg_tables WHERE schemaname = 'patient' AND tablename = 'patient' LIMIT 1",
                    [],
                    dbconn
                )
                nrow(checkResult) > 0
            end
        catch
            false
        end

        # Test with invalid key (should return false)
        req_invalid = Dict{Symbol,Any}(
            :method => "POST",
            :params => Dict{Symbol,Any}(:appuser => missing),
            :data => Vector{UInt8}(JSON.json(["invalid", "wrong", "key", "words"])),
        )

        response_invalid = WebAPI.Endpoints.handle_master_key_set(req_invalid)
        @test response_invalid[:status] == 200
        @test response_invalid[:headers]["Content-Type"] == "application/json"
        result_invalid = JSON.parse(response_invalid[:body])
        @test result_invalid["success"] == false

        if schemaExists
            # Test with valid key
            req_valid = Dict{Symbol,Any}(
                :method => "POST",
                :params => Dict{Symbol,Any}(:appuser => missing),
                :data => Vector{UInt8}(JSON.json(_TestUtils.getDefaultMasterKeyWords())),
            )

            response_valid = WebAPI.Endpoints.handle_master_key_set(req_valid)
            @test response_valid[:status] == 200
            result_valid = JSON.parse(response_valid[:body])
            @test result_valid["success"] == true

            # Verify key was stored in cache
            storedKey = CacheCtrl.getInstanceMasterKey()
            @test !ismissing(storedKey)
            @test !isempty(storedKey)
        else
            @test_skip "Patient schema not available"
        end

        # Test OPTIONS request
        req_options = Dict{Symbol,Any}(:method => "OPTIONS")
        response_options = WebAPI.Endpoints.handle_master_key_set(req_options)
        @test haskey(response_options, :headers)
        @test haskey(response_options[:headers], "Access-Control-Allow-Origin")

    finally
        # Restore original key
        if ismissing(originalKey) || isempty(originalKey)
            CacheCtrl.set("master_key", "")
        else
            CacheCtrl.set("master_key", originalKey)
        end
    end
end

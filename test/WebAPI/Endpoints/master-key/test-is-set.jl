include("__prerequisite.jl")

@testset "Test master-key is-set endpoint" begin
    # Test OPTIONS request
    req_options = Dict{Symbol,Any}(:method => "OPTIONS")
    response_options = WebAPI.Endpoints.handle_master_key_is_set(req_options)
    @test haskey(response_options, :headers)
    @test haskey(response_options[:headers], "Access-Control-Allow-Origin")

    # Test GET request
    req_get = Dict{Symbol,Any}(
        :method => "GET",
        :params => Dict{Symbol,Any}(:appuser => missing),
        :data => Vector{UInt8}(),
    )

    response_get = WebAPI.Endpoints.handle_master_key_is_set(req_get)
    @test response_get[:status] == 200
    @test response_get[:headers]["Content-Type"] == "application/json"
    result = JSON.parse(response_get[:body])
    @test haskey(result, "isSet")
    @test result["isSet"] isa Bool

    # If a key is currently set, the response should be true
    originalKey = CacheCtrl.getInstanceMasterKey()

    try
        # Set a known value
        CacheCtrl.set("master_key", "test_value")
        response_set = WebAPI.Endpoints.handle_master_key_is_set(req_get)
        @test response_set[:status] == 200
        result_set = JSON.parse(response_set[:body])
        @test result_set["isSet"] == true

        # Set an empty value (should still return false)
        CacheCtrl.set("master_key", "")
        response_empty = WebAPI.Endpoints.handle_master_key_is_set(req_get)
        result_empty = JSON.parse(response_empty[:body])
        @test result_empty["isSet"] == false
    finally
        # Restore original
        if ismissing(originalKey) || isempty(originalKey)
            CacheCtrl.set("master_key", "")
        else
            CacheCtrl.set("master_key", originalKey)
        end
    end
end
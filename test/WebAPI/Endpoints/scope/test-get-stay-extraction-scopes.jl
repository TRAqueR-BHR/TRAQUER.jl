include("__prerequisite.jl")

@testset "Test get-stay-extraction-scopes endpoint" begin
    _TestUtils.setDefaultMasterKey()
    dbconn = TRAQUERUtil.openDBConn()

    try
        # Create carrier patient
        history = _TestUtils.createDummyHistoryOfACarrierPatient(dbconn)

        req_with_scope = Dict{Symbol,Any}(
            :method => "POST",
            :params => Dict{Symbol,Any}(:appuser => missing),
            :data => Vector{UInt8}(JSON.json(_TestUtils.getDefaultMasterKeyWords())),
        )

        response_with_scope =
            WebAPI.Endpoints.handle_scope_get_stay_extraction_scopes(req_with_scope)
        @test response_with_scope[:status] == 200
        @test response_with_scope[:headers]["Content-Type"] == "application/json"
        @info "body_with_scope before parsing " response_with_scope[:body]
        response_with_scope[:body] |>
        n -> open(joinpath("tmp","json", "endpoint-get-stay-extraction-scopes.json"), "w") do f
            write(f, n)
        end
        body_with_scope = JSON.parse(response_with_scope[:body])
        @info "body_with_scope " body_with_scope
        # Should have at least one DTO covering the patient's stay
        @test length(body_with_scope) >= 1
        dto = first(body_with_scope)
        @test haskey(dto, "monitoredPatientRef")
        @test haskey(dto, "periodOiStartTime")
        @test haskey(dto, "periodOiEndTime")
        @test haskey(dto, "requestTime")
        @test !ismissing(dto["monitoredPatientRef"])
    finally
        #TRAQUERUtil.rollbackDBTransaction(dbconn)
        TRAQUERUtil.closeDBConn(dbconn)
    end
end

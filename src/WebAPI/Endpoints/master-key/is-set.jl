# GET /api/master-key/is-set
function WebAPI.Endpoints.handle_master_key_is_set(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "/api/master-key/is-set"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(
            :body => String(JSON.json(missing)),
            :headers => Dict(
                "Content-Type" => "text/plain",
                "Access-Control-Allow-Origin" => "*",
            ),
            :status => status_code,
        )
    end

    isSet = false
    error = nothing

    status_code = try
        masterKey = MasterKeyCtrl.getMasterKey()
        isSet = !ismissing(masterKey) && !isempty(masterKey)
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    responseBody = if status_code == 200
        String(JSON.json(Dict("isSet" => isSet)))
    else
        String(JSON.json(string(error)))
    end

    return Dict(
        :body => responseBody,
        :headers => Dict(
            "Content-Type" => "application/json",
            "Access-Control-Allow-Origin" => "*",
        ),
        :status => status_code,
    )
end
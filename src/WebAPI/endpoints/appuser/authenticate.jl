
# POST /api/authenticate
function WebAPI.handle_authenticate(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/authenticate"
    @info "API $apiURL"

    result = missing
    error  = nothing

    status_code = try
        obj     = JSON.parse(String(req[:data]))
        appuser = AppuserCtrl.authenticate(obj["login"], obj["password"])
        result  = String(JSON.json(appuser))
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    if status_code != 200
        result = String(JSON.json(string(error)))
    end

    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

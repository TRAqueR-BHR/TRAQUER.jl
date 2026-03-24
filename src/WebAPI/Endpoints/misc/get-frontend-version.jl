
# POST /api/misc/get-current-frontend-version  (no JWT required)
function WebAPI.Endpoints.handle_misc_get_frontend_version(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "/api/misc/get-current-frontend-version"

    frontendVersion = missing
    error           = nothing

    status_code = try
        frontendVersion = TRAQUERUtil.getCurrentFrontendVersion()
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(frontendVersion)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

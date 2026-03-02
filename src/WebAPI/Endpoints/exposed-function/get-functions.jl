
# POST /api/exposed-function/get-functions
function WebAPI.Endpoints.handle_exposed_function_get(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/exposed-function/get-functions"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    functions = missing
    error     = nothing
    appuser   = missing

    status_code = try
        appuser   = req[:params][:appuser]
        functions = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                ExposedFunctionCtrl.getFunctions(appuser, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(functions)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

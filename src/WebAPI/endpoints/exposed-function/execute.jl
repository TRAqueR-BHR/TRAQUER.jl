
# POST /api/exposed-function/execute
function WebAPI.handle_exposed_function_execute(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/exposed-function/execute"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    startSuccessful = missing
    error           = nothing
    appuser         = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        obj             = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                              JSON.parse(String(req[:data])))
        exposedFunction = json2entity(ExposedFunction, obj["exposedFunction"])
        args            = json2entity.(ExposedFunctionArgument, obj["args"])

        startSuccessful = TRAQUERUtil.executeOnBgThread() do
            ExposedFunctionCtrl.execute(exposedFunction, args, appuser, cryptPwd)
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(startSuccessful)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

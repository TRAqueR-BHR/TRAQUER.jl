
# POST /api/appuser/get-all-users
function WebAPI.handle_appuser_get_all_users(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/appuser/get-all-users"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    queryResult = missing
    error       = nothing
    appuser     = missing

    status_code = try
        appuser     = req[:params][:appuser]
        queryResult = AppuserCtrl.getAppusersForListing(appuser)
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        rethrow(e)
    end

    result = status_code == 200 ? String(JSON.json(queryResult)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

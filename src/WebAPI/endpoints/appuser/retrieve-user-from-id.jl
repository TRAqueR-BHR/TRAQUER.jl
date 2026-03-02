
# POST /api/appuser/retrieve-user-from-id
function WebAPI.handle_appuser_retrieve_user_from_id(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/appuser/retrieve-user-from-id"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    appUser = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser = req[:params][:appuser]
        obj     = JSON.parse(String(req[:data]))
        @info obj["appuser.id"]
        appUser = Controller.retrieveOneEntity(
            Appuser(id = obj["appuser.id"]),
            true,
            true,
        )
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(appUser)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

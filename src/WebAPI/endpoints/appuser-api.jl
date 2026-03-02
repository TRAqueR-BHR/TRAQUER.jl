
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
api_routes = (api_routes..., route("/api/authenticate", WebAPI.handle_authenticate))


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
api_routes = (api_routes..., route("/api/appuser/retrieve-user-from-id", WebAPI.handle_appuser_retrieve_user_from_id))


# POST /api/appuser/save
function WebAPI.handle_appuser_save(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "/api/appuser/save"

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
        obj    = JSON.parse(String(req[:data]))
        entity = json2Entity(Appuser, obj)
        editor = req[:params][:appuser]
        appuser = editor

        if ismissing(entity.id)
            appUser = Controller.persist!(entity; creator = editor)
        else
            appUser = Controller.update!(entity; editor = editor, updateVectorProps = true)
        end

        appUser = Controller.retrieveOneEntity(Appuser(id = appUser.id), true, true)
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
api_routes = (api_routes..., route("/api/appuser/save", WebAPI.handle_appuser_save))


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
api_routes = (api_routes..., route("/api/appuser/get-all-users", WebAPI.handle_appuser_get_all_users))

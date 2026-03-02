
# GET /api/role/all-composed-roles/:appuser_type
function WebAPI.handle_role_all_composed_by_type(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/role/all-composed-roles/:appuser_type"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    roles   = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser     = req[:params][:appuser]
        appuserType = string2enum(AppuserType.APPUSER_TYPE, req[:params][:appuser_type])
        roles       = AppuserCtrl.getComposedRolesAccessibleToUser(appuser; appuserType = appuserType)
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(roles)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/role/all-composed-roles/:appuser_type", WebAPI.handle_role_all_composed_by_type))


# POST /api/role/all-composed-roles
function WebAPI.handle_role_all_composed(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/role/all-composed-roles"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    roles   = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser = req[:params][:appuser]
        roles   = AppuserCtrl.getComposedRolesAccessibleToUser(appuser)
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(roles)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/role/all-composed-roles", WebAPI.handle_role_all_composed))


# POST /api/role/composed-roles-for-listing
function WebAPI.handle_role_composed_for_listing(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/role/composed-roles-for-listing"
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
        queryResult = AppuserCtrl.getComposedRolesForListing(appuser)
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(queryResult)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/role/composed-roles-for-listing", WebAPI.handle_role_composed_for_listing))

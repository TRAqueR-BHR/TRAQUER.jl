#
# Get all the composed roles handled by current user for given Appuser Type
#
new_route = route("/api/role/all-composed-roles/:appuser_type", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /role/all-composed-roles/:appuser_type"

    # Check if the user is allowed
    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                      "Access-Control-Allow-Origin" => "*"),
                    :status => status_code
                     )
    end

    obj = JSON.parse(String(req[:data]))

    #
    # Heart of the API
    #

    # Initialize results
    roles::Union{Missing,Vector{Role}} = missing
    error = nothing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        appuserType =
            string2enum(AppuserType.APPUSER_TYPE,
                        req[:params][:appuser_type])

        roles = AppuserCtrl.getComposedRolesAccessibleToUser(appuser
                                                         ;appuserType = appuserType)

        200 # status_code

    catch e
        # https://pkg.julialang.org/docs/julia/THl1k/1.1.1/manual/stacktraces.html#Error-handling-1
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom message if the file could not be retrieved
        error = e
        500 # status_code
    end # ENDOF try on status code

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            result = String(JSON.json(roles)) # The client side doesn't really need the message
        else
            result = String(JSON.json(string(error)))
        end
    catch e
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        rethrow(e)
    end

    # Send the result
    Dict(:body => result,
         :headers => Dict("Content-Type" => "application/json",
                          "Access-Control-Allow-Origin" => "*"),
         :status => status_code
        )

end)
api_routes = (api_routes..., new_route) # append the route


#
# Get all the composed roles handled by current user
#
new_route = route("/api/role/all-composed-roles", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /role/all-composed-roles"

    # Check if the user is allowed
    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                      "Access-Control-Allow-Origin" => "*"),
                    :status => status_code
                     )
    end

    obj = JSON.parse(String(req[:data]))

    #
    # Heart of the API
    #

    # Initialize results
    roles::Union{Missing,Vector{Role}} = missing
    error = nothing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        # TODO: Create a function in RoleDAO to restrict the roles visible
        #         to the user calling this API
        roles = AppuserCtrl.getComposedRolesAccessibleToUser(appuser)

        200 # status_code

    catch e
        # https://pkg.julialang.org/docs/julia/THl1k/1.1.1/manual/stacktraces.html#Error-handling-1
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom message if the file could not be retrieved
        error = e
        500 # status_code
    end # ENDOF try on status code

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            result = String(JSON.json(roles)) # The client side doesn't really need the message
        else
            result = String(JSON.json(string(error)))
        end
    catch e
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        rethrow(e)
    end

    # Send the result
    Dict(:body => result,
         :headers => Dict("Content-Type" => "application/json",
                          "Access-Control-Allow-Origin" => "*"),
         :status => status_code
        )

end)
api_routes = (api_routes..., new_route) # append the route


#
# Get all composed roles for listing
#
new_route = route("/api/role/composed-roles-for-listing", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /role/composed-roles-for-listing"

    # Check if the user is allowed
    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                      "Access-Control-Allow-Origin" => "*"),
                    :status => status_code
                     )
    end


    #
    # Heart of the API
    #

    # Initialize results
    queryResult = missing
    error = nothing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        queryResult = AppuserCtrl.getComposedRolesForListing(appuser)

        200 # status_code

    catch e
        # https://pkg.julialang.org/docs/julia/THl1k/1.1.1/manual/stacktraces.html#Error-handling-1
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom message if the file could not be retrieved
        error = e
        500 # status_code
    end # ENDOF try on status code

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            result = String(JSON.json(queryResult)) # The client side doesn't really need the message
        else
            result = String(JSON.json(string(error)))
        end
    catch e
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        rethrow(e)
    end

    # Send the result
    Dict(:body => result,
         :headers => Dict("Content-Type" => "application/json",
                          "Access-Control-Allow-Origin" => "*"),
         :status => status_code
        )

end)
api_routes = (api_routes..., new_route) # append the route

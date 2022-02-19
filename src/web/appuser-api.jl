# curl -d '{"login":"mylogin", "password":"mypassword"}' -H "Content-Type: application/json" -X POST http://localhost:8082/createAppuser/
new_route = route("/authenticate", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    obj = JSON.parse(String(req[:data]))

    @info "API /authenticate with login[$(obj["login"])]"

    appuser = missing
    error = nothing

    status_code = try
        appuser = AppuserCtrl.authenticate(obj["login"],
                                           obj["password"])
        200

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
            result = String(JSON.json(appuser)) # The client side doesn't really need the message
        else
            result = String(JSON.json(error))
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
# Retrieve one appUser
#
new_route = route("/appuser/retrieve-user-from-id", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /appuser/retrieve-user-from-id"

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
    appUser::Union{Missing,Appuser} = missing
    error = nothing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        @info obj["appuser.id"]

        appUser_filter = Appuser(id = obj["appuser.id"])

        appUser =
            Controller.retrieveOneEntity(
                                       appUser_filter,
                                       true, # complexProps
                                       true # retrieve complex properties
                                      )

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
            result = String(JSON.json(appUser)) # The client side doesn't really need the message
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
# Create/Update a appUser
#
new_route = route("/appuser/save", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "/appuser/save"

    #
    # Check if the user is allowed
    #
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
    error = nothing
    appUser = missing

    status_code = try

    # Create the dictionary from the JSON
    obj = JSON.parse(String(req[:data]))

    # Create the entity from the JSON Dict
    entity::Appuser = json2Entity(Appuser,obj)

    # Get the user as extracted from the JWT
    editor = req[:params][:appuser]

    # If entity has no ID set, we consider that it's a creation
    if (ismissing(entity.id))
        appUser = Controller.persist!(entity;
                                      creator = editor)
    # If entity has an ID, we consider that it's an update
    else
        appUser = Controller.update!(entity;
                                     editor = editor,
                                     updateVectorProps = true # update vector properties
                                     )
    end

    200 # status code

    catch e
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom appUser if the file could not be retrieved
        error = e
        500 # status_code

    end

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            result = String(JSON.json(appUser)) # The client side doesn't really need the appUser
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
# Retrieve all users
#
new_route = route("/appuser/get-all-users", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /appuser/get-all-users"

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

        queryResult =
            Controller.User.getAllUsers(appuser)

        200 # status_code

    catch e
        # https://pkg.julialang.org/docs/julia/THl1k/1.1.1/manual/stacktraces.html#Error-handling-1
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom message if the file could not be retrieved
        # error = e
        500 # status_code
    end # ENDOF try on status code

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            println(JSON.json(queryResult))
            result = String(JSON.json(queryResult))
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

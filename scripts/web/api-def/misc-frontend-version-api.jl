# curl -d '{"login":"mylogin", "password":"mypassword"}' -H "Content-Type: application/json" -X POST http://localhost:8082/createAppuser/
# curl -d '{}' -H "Content-Type: application/json" -X POST http://localhost:8083/misc/get-current-frontend-version/
new_route = route("/api/misc/get-current-frontend-version", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "/misc/get-current-frontend-version"

    frontendVersion = missing
    error = nothing
    appuser::Union{Nothing, Appuser} = nothing # Needs to be declared here to have it
                                               # available in the catch block

    status_code = try

        frontendVersion = TRAQUERUtil.getCurrentFrontendVersion()

        200

    catch e
        # https://pkg.julialang.org/docs/julia/THl1k/1.1.1/manual/stacktraces.html#Error-handling-1
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()), appuser)
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
            result = String(JSON.json(frontendVersion)) # The client side doesn't really need the message
        else
            result = String(JSON.json(error))
        end
    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()), appuser)
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

#
# Execute pending tasks
#
new_route = route("/api/task-waiting-for-user-execution/execute-pending-tasks", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    # Initiate logging (see below for the serialization)
    apiURL = "/api/task-waiting-for-user-execution/execute-pending-tasks"
    @info "API $apiURL"
    apiInTime = now(getTimeZone())

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
    success::Union{Missing,Bool} = missing
    error = nothing

    # Get current user
    appuser::Union{Appuser,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        # Do not use the usual `TRAQUERUtil.executeOnBgThread` because we just want to call
        # the functions without waiting for their returns.
        ThreadPools.spawnbg() do
            TaskWaitingForUserExecutionCtrl.executePendingTasks(cryptPwd)
        end

        success = true

        # Log API usage
        apiOutTime = now(getTimeZone())
        # WebApiUsageCtrl.logAPIUsage(
        #     appuser,
        #     apiURL,
        #     apiInTime,
        #     apiOutTime
        # )

        200 # status_code

    catch e
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom design if the file could not be retrieved
        error = e
        500 # status_code
    end # ENDOF try on status code

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try

        if status_code == 200
            result = String(JSON.json(success)) # The client side doesn't really need the message
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

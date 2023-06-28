#
# Get an instance of EventRequiringAttention
#
new_route = route("/api/event-requiring-attention/get-event", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /api/event-requiring-attention"

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
    error = nothing
    eventRequiringAttention::Union{EventRequiringAttention,Missing} = missing

    status_code = try


        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPRequest(req)

        obj = JSON.parse(String(req[:data]))

        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)
        eventId::AbstractString = obj["eventId"]

        eventRequiringAttention = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_one_entity(
                    EventRequiringAttention(id = eventId),
                    true,
                    dbconn
                )
            end
        end

        200 # status code

    catch e
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom design if the file could not be retrieved
        error = e
        500 # status_code

    end

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            result = String(JSON.json(eventRequiringAttention)) # The client side doesn't really need the message
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
# Update instance of EventRequiringAttention
#
new_route = route("/api/event-requiring-attention/update", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /event-requiring-attention/update"

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
    error = nothing
    eventRequiringAttention::Union{Missing,EventRequiringAttention} = missing

    status_code = try


        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPRequest(req)

        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        eventRequiringAttention = json2entity(EventRequiringAttention, obj)

        # Check that the infectious status is properly loaded
        if ismissing(eventRequiringAttention.eventType)
            error("Cannot update an eventRequiringAttention if not properly loaded")
        end

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        @info "eventRequiringAttention[$(eventRequiringAttention.id)]"

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.update_entity!(
                    eventRequiringAttention, dbconn
                )
            end
        end


        200 # status code

    catch e
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom design if the file could not be retrieved
        error = e
        500 # status_code

    end

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            result = String(JSON.json(eventRequiringAttention)) # The client side doesn't really need the message
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

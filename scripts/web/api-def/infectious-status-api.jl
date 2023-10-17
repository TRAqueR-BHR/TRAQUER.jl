#
# Listing of infectious status
#
new_route = route("/api/infectious-status/listing", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/infectious-status/listing"
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
    error = nothing
    query_result::Union{Dict,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        obj = JSON.parse(String(req[:data]))

        # @info String(req[:data])
        # Create the dictionary from the JSON
        # serialize("tmp/json_str.jld",req[:data])

        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)
        obj["pageNum"] += 1 # Pagination starts at 0 on the UI

        query_result = InfectiousStatusCtrl.
            getInfectiousStatusForListing(obj["pageSize"],
                                          obj["pageNum"],
                                          obj["cols"]
                                         ;cryptPwd = cryptPwd)

        # Log API usage
        apiOutTime = now(getTimeZone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

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
            result = String(JSON.json(query_result)) # The client side doesn't really need the message
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
# Upsert infectious status
#
new_route = route("/api/infectious-status/upsert", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/infectious-status/upsert"
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
    error = nothing
    infectiousStatus::Union{Missing,InfectiousStatus} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        infectiousStatus = json2entity(InfectiousStatus, obj)

        # Check that the infectious status is properly loaded
        if ismissing(infectiousStatus.infectiousAgent)
            error("Cannot update an infectiousStatus if not properly loaded")
        end

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                InfectiousStatusCtrl.upsert!(
                    infectiousStatus, dbconn
                )
            end
        end

        # Log API usage
        apiOutTime = now(getTimeZone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

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
            result = String(JSON.json(infectiousStatus)) # The client side doesn't really need the message
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
# Delete infectious status
#
new_route = route("/api/infectious-status/delete", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/infectious-status/delete"
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
    error = nothing
    infectiousStatus::Union{Missing,InfectiousStatus} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        infectiousStatus = json2entity(InfectiousStatus, obj)

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                InfectiousStatusCtrl.delete(
                    infectiousStatus, dbconn
                )
            end
        end

        # Log API usage
        apiOutTime = now(getTimeZone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

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
            result = String(JSON.json(infectiousStatus)) # The client side doesn't really need the message
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
# Get instances of InfectiousStatus from an InfectiousStatus used as a filter
#
new_route = route("/api/infectious-status/get-infectious-status-from-infectious-status-filter", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/infectious-status/get-infectious-status-from-infectious-status-filter"
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
    error = nothing
    infectiousStatuses::Union{Vector{InfectiousStatus},Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        @info "obj[\"infectiousStatus\"]" obj["infectiousStatus"]
        infectiousStatusFilter::InfectiousStatus = json2entity(InfectiousStatus, obj["infectiousStatus"])
        includeComplexProperties::Bool = obj["includeComplexProperties"]

        infectiousStatuses = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_entity(
                    infectiousStatusFilter, includeComplexProperties, dbconn
                )
            end
        end

        # Log API usage
        apiOutTime = now(getTimeZone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

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
            result = String(JSON.json(infectiousStatuses)) # The client side doesn't really need the message
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
# Update associations to outbreaks infectious status
#
new_route = route("/api/infectious-status/update-vector-property-outbreak-infectious-status-assoes", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/infectious-status/update-vector-property-outbreak-infectious-status-assoes"
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
    error = nothing
    infectiousStatus::Union{Missing,InfectiousStatus} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        infectiousStatus = json2entity(InfectiousStatus, obj)

        # Check that the infectious status is properly loaded
        if ismissing(infectiousStatus.infectiousAgent)
            error("Cannot update an infectiousStatus if not properly loaded")
        end

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn

                InfectiousStatusCtrl.updateOutbreakInfectiousStatusAssos(
                    infectiousStatus, dbconn
                )

                # # Update the association with the outbreaks
                # PostgresORM.update_vector_property!(
                #     infectiousStatus, :outbreakInfectiousStatusAssoes, dbconn
                # )


            end
        end

        # Log API usage
        apiOutTime = now(getTimeZone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

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
            result = String(JSON.json(infectiousStatus)) # The client side doesn't really need the message
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

#
# Simulate the contact exposures
#
new_route = route("/api/contact-exposure/simulate-contact-exposures", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /api/contact-exposure/simulate-contact-exposures"

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
    exposures::Union{Vector{ContactExposure},Missing} = missing

    status_code = try

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPRequest(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        outbreakConfigUnitAsso::OutbreakConfigUnitAsso = json2entity(
            OutbreakConfigUnitAsso, obj["outbreakConfigUnitAsso"]
        )

        exposures = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                ContactExposureCtrl.generateContactExposures(
                    outbreakConfigUnitAsso, dbconn
                    ;simulate = true
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
            result = String(JSON.json(exposures)) # The client side doesn't really need the message
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
# Generate the contact exposures and infectious statuses
#
new_route = route("/api/contact-exposure/generate-contact-exposures-and-infectious-statuses", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /api/contact-exposure/generate-contact-exposures-and-infectious-statuses"

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
    success::Union{Bool,Missing} = missing

    status_code = try

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPRequest(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        outbreakConfigUnitAsso::OutbreakConfigUnitAsso = json2entity(
            OutbreakConfigUnitAsso, obj["outbreakConfigUnitAsso"]
        )

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                ContactExposureCtrl.generateContactExposuresAndInfectiousStatuses(
                    outbreakConfigUnitAsso, dbconn
                )
            end
        end

        success = true

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

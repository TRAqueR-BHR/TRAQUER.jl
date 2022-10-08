#
# Get the carrier stays related to a OutbreakConfigUnitAsso
#
new_route = route("/api/stay/get-carriers-stays-from-outbreak-config-unit-asso", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /api/stay/get-carriers-stays-from-outbreak-config-unit-asso"

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
    carrierStaysForlisting::Union{DataFrame,Missing} = missing

    status_code = try

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPRequest(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        outbreakConfigUnitAsso::OutbreakConfigUnitAsso = json2entity(
            OutbreakConfigUnitAsso, obj["outbreakConfigUnitAsso"]
        )

        carrierStaysForlisting = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                StayCtrl.getCarriersStaysForListing(
                    outbreakConfigUnitAsso,
                    cryptPwd,
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
            result = String(JSON.json(carrierStaysForlisting)) # The client side doesn't really need the message
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
# Get an instance of Outbreak from an Outbreak used as a filter
#
new_route = route("/api/outbreak/get-outbreak-from-outbreak-filter", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /api/outbreak/get-outbreak-from-outbreak-filter"

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
    outbreak::Union{Outbreak,Missing} = missing

    status_code = try


        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPRequest(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        outbreakFilter::Outbreak = json2entity(Outbreak, obj["outbreak"])
        includeComplexProperties::Bool = obj["includeComplexProperties"]

        outbreak = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_one_entity(
                    outbreakFilter, includeComplexProperties, dbconn
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
            result = String(JSON.json(outbreak)) # The client side doesn't really need the message
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

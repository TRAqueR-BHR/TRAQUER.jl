#
# Get the carrier stays related to a OutbreakUnitAsso
#
new_route = route("/api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso"
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
    carrierStaysForlisting::Union{DataFrame,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        outbreakUnitAsso::OutbreakUnitAsso = json2entity(
            OutbreakUnitAsso, obj["outbreakUnitAsso"]
        )
        infectiousStatusType = TRAQUERUtil.int2enum(
            INFECTIOUS_STATUS_TYPE, obj["infectiousStatusType"]
        )

        carrierStaysForlisting = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn

                StayCtrl.getCarriersOrContactsStays(
                    outbreakUnitAsso,
                    infectiousStatusType,
                    dbconn
                )|>
                n -> StayCtrl.transformStaysForListing(
                    n, # stays
                    cryptPwd,
                    dbconn
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
# Get instances of Stay from an Stay used as a filter
#
new_route = route("/api/stay/get-stay-from-stay-filter", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/stay/get-stay-from-stay-filter"
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
    stays::Union{Vector{Stay},Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        stayFilter::Stay = json2entity(Stay, obj["stay"])
        includeComplexProperties::Bool = obj["includeComplexProperties"]

        stays = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_entity(
                    stayFilter, includeComplexProperties, dbconn
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
            result = String(JSON.json(stays)) # The client side doesn't really need the message
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
# Get the dataframe of hospitalizations dates of a patient
#
new_route = route("/api/stay/get-patient-hospitalizations-dates", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/stay/get-patient-hospitalizations-dates"
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
    df::Union{DataFrame,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        @info "keys(obj)" keys(obj)
        patientFilter::Patient = json2entity(Patient, obj["patient"])

        df = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                StayCtrl.getHospitalizationsDates(
                    patientFilter,
                    dbconn
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
            result = String(JSON.json(df)) # The client side doesn't really need the message
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
# Upsert stay
#
new_route = route("/api/stay/upsert", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/stay/upsert"
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
    stay::Union{Missing,Stay} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        stay = json2entity(Stay, obj)

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        TRAQUERUtil.executeOnBgThread() do
            stay = TRAQUERUtil.createDBConnAndExecute() do dbconn
                stay = StayCtrl.upsert!(
                    stay, dbconn
                )
                ETLCtrl.processNewlyIntegratedData(dbconn)
                return stay
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
            result = String(JSON.json(stay)) # The client side doesn't really need the message
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
# Listing of stays
#
new_route = route("/api/stay/listing", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/stay/listing"
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

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        query_result = StayCtrl.getStaysForListing(
            obj["pageSize"],
            obj["pageNum"],
            obj["cols"]
            ;cryptPwd = cryptPwd
        )

        # Log API usage
        apiOutTime = now(getTimeZone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

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
# Save patient isolation date of a stay that best matches the event requiring attention
#
new_route = route("/api/stay/save-patient-isolation-date-from-event-requiring-attention", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/stay/save-patient-isolation-date-from-event-requiring-attention"
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
    stay::Union{Missing,Stay} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        eventRequiringAttention = json2entity(EventRequiringAttention, obj["event"])
        isolationTime = TRAQUERUtil.browserDateString2ZonedDateTime(
            obj["isolationTime"], TRAQUERUtil.getTimeZone()
        )

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        TRAQUERUtil.executeOnBgThread() do
            stay = TRAQUERUtil.createDBConnAndExecute() do dbconn
                return StayCtrl.saveIsolationTime(
                    eventRequiringAttention,
                    isolationTime,
                    dbconn
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
            result = String(JSON.json(stay)) # The client side doesn't really need the message
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

#
# Get the analyses of a patient
#
new_route = route("/api/analysis/get-analyses-from-patient", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/analysis/get-analyses-from-patient"
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
    appuser::Union{Nothing, Appuser} = nothing # Needs to be declared here to have it
                                               # available in the catch block
    analyses::Union{Vector{AnalysisResult},Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        # Create the entity from the JSON Dict
        patient::Patient = json2entity(
            Patient, obj["patient"]
        )

        analyses = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                AnalysisResultCtrl.getAnalyses(
                    patient,
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
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()), appuser)
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
            result = String(JSON.json(analyses)) # The client side doesn't really need the message
        else
            result = String(JSON.json(string(error)))
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

#
# Upsert analysis result
#
new_route = route("/api/analysis/upsert", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/analysis/upsert"
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
    appuser::Union{Nothing, Appuser} = nothing # Needs to be declared here to have it
                                               # available in the catch block
    analysisResult::Union{Missing,AnalysisResult} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)

        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        analysisResult = json2entity(AnalysisResult, obj["analysisResult"])
        analysisRef = obj["analysisRef"]

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                analysisResult = AnalysisResultCtrl.upsert!(
                    analysisResult,
                    analysisRef,
                    cryptPwd,
                    dbconn
                )
                ETLCtrl.processNewlyIntegratedData(dbconn)
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
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()), appuser)
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
            result = String(JSON.json(analysisResult)) # The client side doesn't really need the message
        else
            result = String(JSON.json(string(error)))
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

#
# Listing of analyses
#
new_route = route("/api/analysis/listing", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/analysis/listing"
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
    appuser::Union{Nothing, Appuser} = nothing # Needs to be declared here to have it
                                               # available in the catch block
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

        query_result = AnalysisResultCtrl.getAnalysesResultsForListing(
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

        200 # status code

    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()), appuser)
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

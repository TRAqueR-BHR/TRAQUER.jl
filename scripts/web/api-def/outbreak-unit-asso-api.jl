#
# Update the outbreak unit asso and update the exposures and contact statuses
#
new_route = route("/api/outbreak-unit-asso/update-asso-and-refresh-exposures-and-contact-statuses", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/contact-exposure/generate-contact-exposures-and-infectious-statuses"
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
    success::Union{Bool,Missing} = missing

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

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                OutbreakUnitAssoCtrl.updateAssoAndRefreshExposuresAndContactStatuses(
                    outbreakUnitAsso, dbconn
                )
            end
        end

        success = true

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
            result = String(JSON.json(success)) # The client side doesn't really need the message
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

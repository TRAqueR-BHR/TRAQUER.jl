#
# Listing of infectious status
#
new_route = route("/api/infectious-status/listing", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    @info "API /infectious-status/listing"

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


        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPRequest(req)

        obj = JSON.parse(String(req[:data]))

        # @info String(req[:data])
        # Create the dictionary from the JSON
        # serialize("tmp/json_str.jld",req[:data])

        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)
        obj["pageNum"] += 1 # Pagination starts at 0 on the UI

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        query_result = InfectiousStatusCtrl.
            getInfectiousStatusForListing(obj["pageSize"],
                                          obj["pageNum"],
                                          obj["cols"]
                                         ;cryptPwd = cryptPwd)

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

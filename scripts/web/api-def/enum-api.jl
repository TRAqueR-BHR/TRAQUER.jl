#
# Get all possible values of a given enum
#
new_route = route("/api/enum/posible-values/:enumType", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    apiURL = "/api/enum/posible-values/:enumType"
    @info "API $apiURL"
    apiInTime = now(getTimezone())

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
    possibleValues::Union{Missing,Vector{Any}} = missing
    error = nothing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        # Convert string to Enum datatype.
        # NOTE: This requires that the enum should be exported in enums.jl
        #         (eg. 'export CURRENCY') and imported in using.jl
        #         (eg. 'using Merchmgt.Enums.Currency')
        enumType::DataType = @eval $(Symbol(req[:params][:enumType]))

        possibleValues = TRAQUERUtil.listEnums(enumType
                                              ;appuser = appuser)

        200 # status_code

    catch e
        # https://pkg.julialang.org/docs/julia/THl1k/1.1.1/manual/stacktraces.html#Error-handling-1
        formatExceptionAndStackTrace(e,
                                     stacktrace(catch_backtrace()))
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
            result = String(JSON.json(possibleValues)) # The client side doesn't really need the message
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

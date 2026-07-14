# GET/POST /api/enum/posible-values/:enumType
function WebAPI.Endpoints.handle_enum_possible_values(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/enum/posible-values/:enumType"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(
            :body => String(JSON.json(missing)),
            :headers => Dict(
                "Content-Type" => "text/plain",
                "Access-Control-Allow-Origin" => "*",
            ),
            :status => status_code,
        )
    end

    possibleValues = missing
    error = nothing
    appuser = missing

    status_code = try
        appuser = req[:params][:appuser]
        enumType = @eval $(Symbol(req[:params][:enumType]))
        possibleValues = TRAQUERUtil.listEnums(enumType; appuser = appuser)
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    responseBody = if status_code == 200
        String(JSON.json(possibleValues))
    else
        String(JSON.json(string(error)))
    end

    return Dict(
        :body => responseBody,
        :headers => Dict(
            "Content-Type" => "application/json",
            "Access-Control-Allow-Origin" => "*",
        ),
        :status => status_code,
    )
end

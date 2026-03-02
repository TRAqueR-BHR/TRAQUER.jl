function WebAPI.mux_get_appuser_from_jwt(app, req)

    @info "In JWT filter"

    if req[:method] == "OPTIONS"
        return app(req)
    end

    headers_dict = Dict(
        zip(
            lowercase.(getproperty.(req[:headers], :first)),
            getproperty.(req[:headers], :second),
        ),
    )

    if !haskey(req, :params)
        req[:params] = Dict{Any,Any}()
    end
    req[:params][:appuser] = missing

    if (req[:path] in apis_paths_wo_jwt ||
        (length(req[:path]) >= 2 && req[:path][1] == "file-upload" &&
            req[:path][2] == "get-pdf"))
        @info "[$(string(req[:uri]))] does not require JWT authentication"
        return app(req)
    end

    if haskey(headers_dict, "browser-timezone")
        req[:params][:browserTimezone] = TimeZones.TimeZone(
            headers_dict["browser-timezone"],
            TimeZones.Class(:FIXED) | TimeZones.Class(:STANDARD) | TimeZones.Class(:LEGACY),
        )
    end

    if haskey(headers_dict, "authorization")
        jwtkeyset, jwtkeyid = _ensure_jwt_keyset()
        jwt_str = replace(replace(headers_dict["authorization"], "Bearer" => ""), " " => "")
        jwt = JWT(; jwt = jwt_str)
        validate!(jwt, jwtkeyset, jwtkeyid)

        if !isvalid(jwt)
            @info "Invalid credentials"
            return Dict(
                :status => 401,
                :headers => Dict(
                    "Content-Type" => "application/json",
                    "WWW-Authenticate" => "Bearer error=\"invalid_token\""
                ),
                :body => """{"error": "Invalid or expired token"}"""
            )
        else
            jwt_dict = JWTs.claims(jwt)
            req[:params][:appuser] = try
                Controller.retrieveOneEntity(
                    Appuser(login = jwt_dict["login"]),
                    true,
                    true,
                )
            catch e
                @warn TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
                missing
            end
        end
    else
        @info "No Authorization header"
        return Dict(
            :status => 401,
            :headers => Dict("Content-Type" => "application/json"),
            :body => """{"error": "Missing or invalid Authorization header!"}"""
        )
    end

    return app(req)
end

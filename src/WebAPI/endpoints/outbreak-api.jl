
# POST /api/outbreak/get-outbreak-from-event-requiring-attention
function WebAPI.handle_outbreak_get_from_event(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/get-outbreak-from-event-requiring-attention"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    outbreak = missing
    error    = nothing
    appuser  = missing

    status_code = try
        appuser                  = req[:params][:appuser]
        cryptPwd                 = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                       JSON.parse(String(req[:data])))
        eventRequiringAttention  = json2entity(EventRequiringAttention, obj["eventRequiringAttention"])
        includeComplexProperties = obj["includeComplexProperties"]

        outbreak = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                OutbreakCtrl.getOutbreakFromEventRequiringAttention(
                    eventRequiringAttention, includeComplexProperties, dbconn
                )
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(outbreak)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/outbreak/get-outbreak-from-event-requiring-attention", WebAPI.handle_outbreak_get_from_event))


# POST /api/outbreak/get-outbreak-from-outbreak-filter
function WebAPI.handle_outbreak_get_from_filter(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/get-outbreak-from-outbreak-filter"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    outbreak = missing
    error    = nothing
    appuser  = missing

    status_code = try
        appuser                  = req[:params][:appuser]
        cryptPwd                 = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                       JSON.parse(String(req[:data])))
        outbreakFilter           = json2entity(Outbreak, obj["outbreak"])
        includeComplexProperties = obj["includeComplexProperties"]

        outbreak = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_one_entity(outbreakFilter, includeComplexProperties, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(outbreak)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/outbreak/get-outbreak-from-outbreak-filter", WebAPI.handle_outbreak_get_from_filter))


# POST /api/outbreak/get-outbreak-unit-assos-from-infectious-status
function WebAPI.handle_outbreak_get_unit_assos_from_infectious_status(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/get-outbreak-unit-assos-from-infectious-status"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    assos   = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser                  = req[:params][:appuser]
        cryptPwd                 = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                       JSON.parse(String(req[:data])))
        infectiousStatus         = json2entity(InfectiousStatus, obj["infectiousStatus"])
        includeComplexProperties = obj["includeComplexProperties"]

        assos = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                OutbreakCtrl.getOutbreakUnitAssosFromInfectiousStatus(
                    infectiousStatus, includeComplexProperties, dbconn
                )
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(assos)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/outbreak/get-outbreak-unit-assos-from-infectious-status", WebAPI.handle_outbreak_get_unit_assos_from_infectious_status))


# POST /api/outbreak/initialize
function WebAPI.handle_outbreak_initialize(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/initialize"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    outbreak = missing
    error    = nothing
    appuser  = missing

    status_code = try
        appuser                 = req[:params][:appuser]
        @info "appuser[$(appuser.id)]"
        cryptPwd                = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                     = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                      JSON.parse(String(req[:data])))
        firstInfectiousStatus   = json2entity(InfectiousStatus, obj["firstInfectiousStatus"])
        outbreakName            = obj["outbreakName"]
        criticity               = TRAQUERUtil.int2enum(OUTBREAK_CRITICITY, obj["criticity"])
        refTime                 = TRAQUERUtil.browserDateString2ZonedDateTime(obj["refTime"])

        outbreak = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                OutbreakCtrl.initializeOutbreak(
                    outbreakName, firstInfectiousStatus, criticity, refTime, dbconn
                )
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        if e isa CapturedException && e.ex isa OutbreakNameAlreadyUsedError
            error = e.ex.msg
            409
        else
            error = e
            500
        end
    end

    result = status_code == 200 ? String(JSON.json(outbreak)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/outbreak/initialize", WebAPI.handle_outbreak_initialize))


# POST /api/outbreak/get-outbreak-unit-assos-from-outbreak
function WebAPI.handle_outbreak_get_unit_assos_from_outbreak(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/get-outbreak-unit-assos-from-outbreak"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    assos   = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        outbreak = json2entity(Outbreak, obj["outbreak"])

        assos = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_entity(OutbreakUnitAsso(outbreak = outbreak), true, dbconn) |>
                n -> sort(n, by = x -> x.unit.name)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(assos)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/outbreak/get-outbreak-unit-assos-from-outbreak", WebAPI.handle_outbreak_get_unit_assos_from_outbreak))


# POST /api/outbreak/get-outbreak-infectious-status-assos-from-infectious-status
function WebAPI.handle_outbreak_get_infectious_status_assos(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/get-outbreak-infectious-status-assos-from-infectious-status"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    assos   = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser          = req[:params][:appuser]
        cryptPwd         = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj              = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                               JSON.parse(String(req[:data])))
        infectiousStatus = json2entity(InfectiousStatus, obj["infectiousStatus"])

        assos = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_entity(
                    OutbreakInfectiousStatusAsso(infectiousStatus = infectiousStatus), true, dbconn
                )
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(assos)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/outbreak/get-outbreak-infectious-status-assos-from-infectious-status", WebAPI.handle_outbreak_get_infectious_status_assos))


# POST /api/outbreak/get-outbreaks-that-can-be-associated-to-infectious-status
function WebAPI.handle_outbreak_get_associable(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/get-outbreaks-that-can-be-associated-to-infectious-status"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    outbreaks = missing
    error     = nothing
    appuser   = missing

    status_code = try
        appuser          = req[:params][:appuser]
        cryptPwd         = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj              = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                               JSON.parse(String(req[:data])))
        infectiousStatus = json2entity(InfectiousStatus, obj["infectiousStatus"])

        outbreaks = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                OutbreakCtrl.getOutbreaksThatCanBeAssociated(infectiousStatus, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(outbreaks)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/outbreak/get-outbreaks-that-can-be-associated-to-infectious-status", WebAPI.handle_outbreak_get_associable))


# POST /api/outbreak/save
function WebAPI.handle_outbreak_save(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/save"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    outbreak = missing
    error    = nothing
    appuser  = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        outbreak = json2entity(Outbreak, obj)

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.update_entity!(outbreak, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(outbreak)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/outbreak/save", WebAPI.handle_outbreak_save))

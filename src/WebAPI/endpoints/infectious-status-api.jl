
# POST /api/infectious-status/listing
function WebAPI.handle_infectious_status_listing(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/infectious-status/listing"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    query_result = missing
    error        = nothing
    appuser      = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        obj["pageNum"] += 1

        query_result = InfectiousStatusCtrl.getInfectiousStatusForListing(
            obj["pageSize"], obj["pageNum"], obj["cols"]
            ; cryptPwd = cryptPwd
        )
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(query_result)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/infectious-status/listing", WebAPI.handle_infectious_status_listing))


# POST /api/infectious-status/upsert
function WebAPI.handle_infectious_status_upsert(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/infectious-status/upsert"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    infectiousStatus = missing
    error            = nothing
    appuser          = missing

    status_code = try
        appuser          = req[:params][:appuser]
        cryptPwd         = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj              = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                               JSON.parse(String(req[:data])))
        infectiousStatus = json2entity(InfectiousStatus, obj)

        if ismissing(infectiousStatus.infectiousAgent)
            error("Cannot update an infectiousStatus if not properly loaded")
        end

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                InfectiousStatusCtrl.upsert!(infectiousStatus, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(infectiousStatus)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/infectious-status/upsert", WebAPI.handle_infectious_status_upsert))


# POST /api/infectious-status/delete
function WebAPI.handle_infectious_status_delete(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/infectious-status/delete"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    infectiousStatus = missing
    error            = nothing
    appuser          = missing

    status_code = try
        appuser          = req[:params][:appuser]
        cryptPwd         = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj              = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                               JSON.parse(String(req[:data])))
        infectiousStatus = json2entity(InfectiousStatus, obj)

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                InfectiousStatusCtrl.delete(infectiousStatus, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(infectiousStatus)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/infectious-status/delete", WebAPI.handle_infectious_status_delete))


# POST /api/infectious-status/get-infectious-status-from-infectious-status-filter
function WebAPI.handle_infectious_status_get_from_filter(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/infectious-status/get-infectious-status-from-infectious-status-filter"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    infectiousStatuses = missing
    error              = nothing
    appuser            = missing

    status_code = try
        appuser                  = req[:params][:appuser]
        cryptPwd                 = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                       JSON.parse(String(req[:data])))
        infectiousStatusFilter   = json2entity(InfectiousStatus, obj["infectiousStatus"])
        includeComplexProperties = obj["includeComplexProperties"]

        infectiousStatuses = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_entity(infectiousStatusFilter, includeComplexProperties, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(infectiousStatuses)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/infectious-status/get-infectious-status-from-infectious-status-filter", WebAPI.handle_infectious_status_get_from_filter))


# POST /api/infectious-status/update-vector-property-outbreak-infectious-status-assoes
function WebAPI.handle_infectious_status_update_outbreak_assos(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/infectious-status/update-vector-property-outbreak-infectious-status-assoes"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    infectiousStatus = missing
    error            = nothing
    appuser          = missing

    status_code = try
        appuser          = req[:params][:appuser]
        cryptPwd         = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj              = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                               JSON.parse(String(req[:data])))
        infectiousStatus = json2entity(InfectiousStatus, obj)

        if ismissing(infectiousStatus.infectiousAgent)
            error("Cannot update an infectiousStatus if not properly loaded")
        end

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                InfectiousStatusCtrl.updateOutbreakInfectiousStatusAssos(infectiousStatus, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(infectiousStatus)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/infectious-status/update-vector-property-outbreak-infectious-status-assoes", WebAPI.handle_infectious_status_update_outbreak_assos))

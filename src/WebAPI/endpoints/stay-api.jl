
# POST /api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso
function WebAPI.handle_stay_get_carriers_or_contacts(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    carrierStaysForListing = missing
    error                  = nothing
    appuser                = missing

    status_code = try
        appuser              = req[:params][:appuser]
        cryptPwd             = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                  = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                   JSON.parse(String(req[:data])))
        outbreakUnitAsso     = json2entity(OutbreakUnitAsso, obj["outbreakUnitAsso"])
        infectiousStatusType = TRAQUERUtil.int2enum(INFECTIOUS_STATUS_TYPE, obj["infectiousStatusType"])

        carrierStaysForListing = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                StayCtrl.getCarriersOrContactsStays(outbreakUnitAsso, infectiousStatusType, dbconn) |>
                n -> StayCtrl.transformStaysForListing(n, cryptPwd, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(carrierStaysForListing)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso", WebAPI.handle_stay_get_carriers_or_contacts))


# POST /api/stay/get-stay-from-stay-filter
function WebAPI.handle_stay_get_from_filter(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/stay/get-stay-from-stay-filter"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    stays   = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser                  = req[:params][:appuser]
        cryptPwd                 = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                       JSON.parse(String(req[:data])))
        stayFilter               = json2entity(Stay, obj["stay"])
        includeComplexProperties = obj["includeComplexProperties"]

        stays = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_entity(stayFilter, includeComplexProperties, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(stays)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/stay/get-stay-from-stay-filter", WebAPI.handle_stay_get_from_filter))


# POST /api/stay/get-patient-hospitalizations-dates
function WebAPI.handle_stay_get_hospitalization_dates(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/stay/get-patient-hospitalizations-dates"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    df      = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser       = req[:params][:appuser]
        cryptPwd      = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj           = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                            JSON.parse(String(req[:data])))
        @info "keys(obj)" keys(obj)
        patientFilter = json2entity(Patient, obj["patient"])

        df = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                StayCtrl.getHospitalizationsDates(patientFilter, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(df)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/stay/get-patient-hospitalizations-dates", WebAPI.handle_stay_get_hospitalization_dates))


# POST /api/stay/upsert
function WebAPI.handle_stay_upsert(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/stay/upsert"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    stay    = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        stay     = json2entity(Stay, obj)

        TRAQUERUtil.executeOnBgThread() do
            stay = TRAQUERUtil.createDBConnAndExecute() do dbconn
                stay = StayCtrl.upsert!(stay, dbconn)
                ETLCtrl.processNewlyIntegratedData(dbconn)
                return stay
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(stay)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/stay/upsert", WebAPI.handle_stay_upsert))


# POST /api/stay/listing
function WebAPI.handle_stay_listing(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/stay/listing"
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

        query_result = StayCtrl.getStaysForListing(
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
api_routes = (api_routes..., route("/api/stay/listing", WebAPI.handle_stay_listing))


# POST /api/stay/save-patient-isolation-date-from-event-requiring-attention
function WebAPI.handle_stay_save_isolation_date(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/stay/save-patient-isolation-date-from-event-requiring-attention"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    stay    = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser                 = req[:params][:appuser]
        cryptPwd                = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                     = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                      JSON.parse(String(req[:data])))
        eventRequiringAttention = json2entity(EventRequiringAttention, obj["event"])
        isolationTime           = TRAQUERUtil.browserDateString2ZonedDateTime(
                                      obj["isolationTime"], TRAQUERUtil.getTimeZone()
                                  )

        TRAQUERUtil.executeOnBgThread() do
            stay = TRAQUERUtil.createDBConnAndExecute() do dbconn
                StayCtrl.saveIsolationTime(eventRequiringAttention, isolationTime, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        if e isa CapturedException && e.ex isa NoStayFoundError
            error = e.ex.msg
            409
        else
            error = e
            500
        end
    end

    result = status_code == 200 ? String(JSON.json(stay)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/stay/save-patient-isolation-date-from-event-requiring-attention", WebAPI.handle_stay_save_isolation_date))


# POST /api/stay/delete-isolation-time
function WebAPI.handle_stay_delete_isolation_time(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/stay/delete-isolation-time"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    stay    = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        stay     = json2entity(Stay, obj)

        TRAQUERUtil.executeOnBgThread() do
            stay = TRAQUERUtil.createDBConnAndExecute() do dbconn
                StayCtrl.deleteIsolationTime(stay, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        if e isa CapturedException && e.ex isa NoStayFoundError
            error = e.ex.msg
            409
        else
            error = e
            500
        end
    end

    result = status_code == 200 ? String(JSON.json(stay)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/stay/delete-isolation-time", WebAPI.handle_stay_delete_isolation_time))

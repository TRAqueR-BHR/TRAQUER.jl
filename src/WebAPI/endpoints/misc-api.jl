
# POST /api/misc/get-current-frontend-version  (no JWT required)
function WebAPI.handle_misc_get_frontend_version(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "/api/misc/get-current-frontend-version"

    frontendVersion = missing
    error           = nothing

    status_code = try
        frontendVersion = TRAQUERUtil.getCurrentFrontendVersion()
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(frontendVersion)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/misc/get-current-frontend-version", WebAPI.handle_misc_get_frontend_version))


# POST /api/misc/name-of-dataset-password-header-for-http-request
function WebAPI.handle_misc_dataset_password_header_name(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "/api/misc/name-of-dataset-password-header-for-http-request"

    nameOfHeader = missing
    error        = nothing

    status_code = try
        nameOfHeader = TRAQUERUtil.getNameOfDatasetPasswordHeaderForHttpRequest()
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(nameOfHeader)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/misc/name-of-dataset-password-header-for-http-request", WebAPI.handle_misc_dataset_password_header_name))


# POST /api/misc/process-newly-integrated-data
function WebAPI.handle_misc_process_newly_integrated_data(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/misc/process-newly-integrated-data"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    processingOutcome = missing
    error             = nothing
    appuser           = missing

    status_code = try
        appuser = req[:params][:appuser]
        obj     = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                      JSON.parse(String(req[:data])))
        processingTime = ZonedDateTime(obj["processingTime"]) |>
            n -> astimezone(n, req[:params][:browserTimezone])

        @info processingTime

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                ETLCtrl.processNewlyIntegratedData(dbconn; forceProcessingTime = processingTime)
            end
        end

        processingOutcome = true
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(processingOutcome)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/misc/process-newly-integrated-data", WebAPI.handle_misc_process_newly_integrated_data))


# POST /api/misc/reset-data
function WebAPI.handle_misc_reset_data(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "/api/misc/reset-data"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    resetOutcome = missing
    error        = nothing
    appuser      = missing

    status_code = try
        appuser = req[:params][:appuser]

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                resetOutcome = MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures(dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(resetOutcome)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/misc/reset-data", WebAPI.handle_misc_reset_data))


# POST /api/misc/process-newly-integrated-data
function WebAPI.Endpoints.handle_misc_process_newly_integrated_data(req)
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

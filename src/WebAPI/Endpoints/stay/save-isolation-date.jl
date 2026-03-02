
# POST /api/stay/save-patient-isolation-date-from-event-requiring-attention
function WebAPI.Endpoints.handle_stay_save_isolation_date(req)
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


# POST /api/outbreak/get-outbreak-from-event-requiring-attention
function WebAPI.Endpoints.handle_outbreak_get_from_event(req)
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

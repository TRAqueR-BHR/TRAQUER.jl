
# POST /api/event-requiring-attention/update
function WebAPI.handle_event_requiring_attention_update(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/event-requiring-attention/update"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    eventRequiringAttention = missing
    error                   = nothing
    appuser                 = missing

    status_code = try
        appuser                 = req[:params][:appuser]
        cryptPwd                = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                     = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                      JSON.parse(String(req[:data])))
        eventRequiringAttention = json2entity(EventRequiringAttention, obj)

        if ismissing(eventRequiringAttention.eventType)
            error("Cannot update an eventRequiringAttention if not properly loaded")
        end

        @info "eventRequiringAttention[$(eventRequiringAttention.id)]"

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.update_entity!(eventRequiringAttention, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(eventRequiringAttention)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end


# POST /api/infectious-status/upsert
function WebAPI.Endpoints.handle_infectious_status_upsert(req)
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


# POST /api/outbreak/initialize
function WebAPI.Endpoints.handle_outbreak_initialize(req)
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

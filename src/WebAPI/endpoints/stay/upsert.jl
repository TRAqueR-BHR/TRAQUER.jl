
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

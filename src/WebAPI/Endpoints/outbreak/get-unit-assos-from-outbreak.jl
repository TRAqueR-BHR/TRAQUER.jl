
# POST /api/outbreak/get-outbreak-unit-assos-from-outbreak
function WebAPI.Endpoints.handle_outbreak_get_unit_assos_from_outbreak(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/outbreak/get-outbreak-unit-assos-from-outbreak"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    assos   = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        outbreak = json2entity(Outbreak, obj["outbreak"])

        assos = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PostgresORM.retrieve_entity(OutbreakUnitAsso(outbreak = outbreak), true, dbconn) |>
                n -> sort(n, by = x -> x.unit.name)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(assos)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

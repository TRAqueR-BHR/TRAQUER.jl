
# POST /api/contact-exposure/simulate-contact-exposures
function WebAPI.handle_contact_exposure_simulate(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/contact-exposure/simulate-contact-exposures"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    exposures = missing
    error     = nothing
    appuser   = missing

    status_code = try
        appuser          = req[:params][:appuser]
        cryptPwd         = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj              = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                               JSON.parse(String(req[:data])))
        outbreakUnitAsso = json2entity(OutbreakUnitAsso, obj["outbreakUnitAsso"])

        exposures = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                ContactExposureCtrl.generateContactExposures(
                    outbreakUnitAsso, dbconn
                    ; simulate = true,
                    excludeIfLessThanMinimumNumberOfHoursForContactStatusCreation = true,
                )
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(exposures)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

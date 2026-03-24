
# POST /api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso
function WebAPI.Endpoints.handle_stay_get_carriers_or_contacts(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/stay/get-carriers-or-contacts-stays-from-outbreak-unit-asso"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    carrierStaysForListing = missing
    error                  = nothing
    appuser                = missing

    status_code = try
        appuser              = req[:params][:appuser]
        cryptPwd             = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj                  = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                                   JSON.parse(String(req[:data])))
        outbreakUnitAsso     = json2entity(OutbreakUnitAsso, obj["outbreakUnitAsso"])
        infectiousStatusType = TRAQUERUtil.int2enum(INFECTIOUS_STATUS_TYPE, obj["infectiousStatusType"])

        carrierStaysForListing = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                StayCtrl.getCarriersOrContactsStays(outbreakUnitAsso, infectiousStatusType, dbconn) |>
                n -> StayCtrl.transformStaysForListing(n, cryptPwd, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(carrierStaysForListing)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

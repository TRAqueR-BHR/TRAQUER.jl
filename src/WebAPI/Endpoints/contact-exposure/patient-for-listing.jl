
# POST /api/contact-exposure/patient-exposures-for-listing
function WebAPI.Endpoints.handle_contact_exposure_patient_for_listing(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/contact-exposure/patient-exposures-for-listing"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    df      = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        patient  = json2entity(Patient, obj)

        df = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                ContactExposureCtrl.getPatientExposuresForListing(patient, cryptPwd, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(df)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

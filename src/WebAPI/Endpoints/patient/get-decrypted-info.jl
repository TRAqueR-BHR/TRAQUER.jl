
# GET /api/patient/get-patient-decrypted-info/:id
function WebAPI.Endpoints.handle_patient_get_decrypted_info(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/patient/get-patient-decrypted-info/:id"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    patientDecryptInfo = missing
    error              = nothing
    appuser            = missing

    status_code = try
        appuser   = req[:params][:appuser]
        cryptPwd  = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end
        patientId = string(req[:params][:id])

        patientDecryptInfo = TRAQUERUtil.executeOnBgThread() do
            PatientCtrl.getPatientDecryptedInfoFromId(patientId, cryptPwd)
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(patientDecryptInfo)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

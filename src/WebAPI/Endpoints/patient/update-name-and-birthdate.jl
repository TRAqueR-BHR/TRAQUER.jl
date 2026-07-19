# POST /api/patient/update-name-and-birthdate
function WebAPI.Endpoints.handle_patient_update_name_and_birthdate(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/patient/update-name-and-birthdate"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(
            :body => String(JSON.json(missing)),
            :headers => Dict(
                "Content-Type" => "text/plain",
                "Access-Control-Allow-Origin" => "*",
            ),
            :status => status_code,
        )
    end

    patient = missing
    error = nothing
    appuser = missing

    status_code = try
        appuser = req[:params][:appuser]
        cryptPwd = MasterKeyCtrl.getMasterKey(failIfMissing = true))
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        obj = JSON.parse(String(req[:data]))
        patient = json2entity(Patient, obj["patient"])
        birthdate = TRAQUERUtil.string2date(obj["birthdate"])

        patient = TRAQUERUtil.executeOnBgThread() do
            PatientCtrl.updatePatientNameAndBirthdate(
                patient,
                obj["firstname"],
                obj["lastname"],
                birthdate,
                cryptPwd,
            )
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    responseBody = if status_code == 200
        String(JSON.json(patient))
    else
        String(JSON.json(string(error)))
    end

    return Dict(
        :body => responseBody,
        :headers => Dict(
            "Content-Type" => "application/json",
            "Access-Control-Allow-Origin" => "*",
        ),
        :status => status_code,
    )
end

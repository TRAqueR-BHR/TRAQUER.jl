#
# Listing of patients
#
new_route = route("/api/patient/listing", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    # Initiate logging (see below for the serialization)
    apiURL = "/api/patient/listing"
    @info "API $apiURL"
    apiInTime = now(getTimeZone())

    # Check if the user is allowed
    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                      "Access-Control-Allow-Origin" => "*"),
                    :status => status_code
                     )
    end

    #
    # Heart of the API
    #

    # Initialize results
    error = nothing
    query_result::Union{Dict,Missing} = missing

    # Get current user
    appuser::Union{Appuser,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        # Get the crypt password from the HTTP request header
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))

        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)
        obj["pageNum"] += 1 # Pagination starts at 0 on the UI


        query_result = TRAQUERUtil.executeOnBgThread() do
            PatientCtrl.getPatientsForListing(
                obj["pageSize"],
                obj["pageNum"],
                obj["cols"],
                ;cryptPwd = cryptPwd
            )
        end

        # Log API usage
        apiOutTime = now(getTimezone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

        200 # status code

    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom design if the file could not be retrieved
        error = e
        500 # status_code

    end

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            result = String(JSON.json(query_result)) # The client side doesn't really need the message
        else
            result = String(JSON.json(string(error)))
        end
    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        rethrow(e)
    end

    # Send the result
    Dict(:body => result,
         :headers => Dict("Content-Type" => "application/json",
                          "Access-Control-Allow-Origin" => "*"),
         :status => status_code
        )

end)
api_routes = (api_routes..., new_route) # append the route


#
# Retrieve the decrypted info from the patient
#
new_route = route("/api/patient/get-decrypted", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    # Initiate logging (see below for the serialization)
    apiURL = "/api/patient/get-decrypted"
    @info "API $apiURL"
    apiInTime = now(getTimeZone())

    # Check if the user is allowed
    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                      "Access-Control-Allow-Origin" => "*"),
                    :status => status_code
                     )
    end

    #
    # Heart of the API
    #

    # Initialize results
    error = nothing
    patientDecrypt::Union{PatientDecrypt,Missing} = missing

    # Get current user
    appuser::Union{Appuser,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]


        # Get the crypt password from the HTTP request header
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        obj = JSON.parse(String(req[:data]))
        obj = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(obj)

        patient = json2entity(Patient, obj)

        patientDecrypt = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PatientCtrl.getPatientDecrypt(
                    patient,
                    cryptPwd,
                    dbconn
                )
            end
        end

        # Log API usage
        apiOutTime = now(getTimezone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

        200 # status code

    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        # rethrow(e) # Do not rethrow the error because we do want to send a
                     #  custom design if the file could not be retrieved
        error = e
        500 # status_code

    end

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try
        if status_code == 200
            result = String(JSON.json(patientDecrypt)) # The client side doesn't really need the message
        else
            result = String(JSON.json(string(error)))
        end
    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        rethrow(e)
    end

    # Send the result
    Dict(:body => result,
         :headers => Dict("Content-Type" => "application/json",
                          "Access-Control-Allow-Origin" => "*"),
         :status => status_code
        )

end)
api_routes = (api_routes..., new_route) # append the route

#
# Retrieve variables values decrypted for a given patient id
#
new_route = route("/api/patient/get-patient-decrypted-info/:id", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    # Initiate logging (see below for the serialization)
    apiURL = "/api/patient/get-patient-decrypted-info/:id"
    @info "API $apiURL"

    # Check if the user is allowed
    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                      "Access-Control-Allow-Origin" => "*"),
                    :status => status_code
                     )
    end

    #
    # Heart of the API
    #

    # Initialize results
    patientDecryptInfo::Union{Missing,DataFrameRow} = missing
    error = nothing

    # Get current user
    appuser::Union{Appuser,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        patientId = string(req[:params][:id])
        patientDecryptInfo = executeOnBgThread() do
            PatientCtrl.getPatientDecryptedInfoFromId(
                patientId,
                cryptPwd)
        end

        # Log API usage
        apiOutTime = now(getTimezone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

        200 # status_code

    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500 # status_code
    end # ENDOF try on status code

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try

        if status_code == 200
            result = String(JSON.json(patientDecryptInfo))
        else
            result = String(JSON.json(string(error)))
        end
    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        rethrow(e)
    end

    # Send the result
    Dict(:body => result,
         :headers => Dict("Content-Type" => "application/json",
                          "Access-Control-Allow-Origin" => "*"),
         :status => status_code
        )

end)
api_routes = (api_routes..., new_route) # append the route

#
# Create a new patient
#
new_route = route("/api/patient/create", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    # Initiate logging (see below for the serialization)
    apiURL = "/api/patient/create"
    @info "API $apiURL"

    # Check if the user is allowed
    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                      "Access-Control-Allow-Origin" => "*"),
                    :status => status_code
                     )
    end

    #
    # Heart of the API
    #

    # Initialize results
    patient::Union{Missing,Patient} = missing
    error = nothing

    # Get current user
    appuser::Union{Appuser,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))

        # Convert the date
        birthdate = TRAQUERUtil.string2date(obj["birthdate"])

        patient = executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                PatientCtrl.createPatient(
                    obj["firstname"],
                    obj["lastname"],
                    birthdate,
                    missing, # ref
                    cryptPwd,
                    dbconn
                )
            end
        end

        # Log API usage
        apiOutTime = now(getTimezone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

        200 # status_code

    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500 # status_code
    end # ENDOF try on status code

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try

        if status_code == 200
            result = String(JSON.json(patient))
        else
            result = String(JSON.json(string(error)))
        end
    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        rethrow(e)
    end

    # Send the result
    Dict(:body => result,
         :headers => Dict("Content-Type" => "application/json",
                          "Access-Control-Allow-Origin" => "*"),
         :status => status_code
        )

end)
api_routes = (api_routes..., new_route) # append the route


#
# Update the name and birthdate
#
new_route = route("/api/patient/update-name-and-birthdate", req -> begin

    # https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request
    if req[:method] == "OPTIONS"
        return(respFor_OPTIONS_req())
    end

    # Initiate logging (see below for the serialization)
    apiURL = "/api/patient/update-name-and-birthdate"

    # Check if the user is allowed
    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                      "Access-Control-Allow-Origin" => "*"),
                    :status => status_code
                     )
    end

    #
    # Heart of the API
    #

    # Initialize results
    patient::Union{Missing,Patient} = missing
    error = nothing

    # Get current user
    appuser::Union{Appuser,Missing} = missing

    status_code = try

        # Get the user as extracted from the JWT
        appuser = req[:params][:appuser]

        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        # Create the dictionary from the JSON
        obj = JSON.parse(String(req[:data]))
        patient = json2entity(Patient,obj["patient"])

        # Convert the date
        birthdate = TRAQUERUtil.string2date(obj["birthdate"])

        patient = executeOnBgThread() do
            PatientCtrl.updatePatientNameAndBirthdate(
                patient,
                obj["firstname"],
                obj["lastname"],
                birthdate,
                cryptPwd)
        end

        # Log API usage
        apiOutTime = now(getTimezone())
        WebApiUsageCtrl.logAPIUsage(
            appuser,
            apiURL,
            apiInTime,
            apiOutTime
        )

        200 # status_code

    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        500 # status_code
    end # ENDOF try on status code

    #
    # Prepare the result
    #
    result::Union{Missing,String} = missing
    try

        if status_code == 200
            result = String(JSON.json(patient))
        else
            result = String(JSON.json(string(error)))
        end
    catch e
        formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        rethrow(e)
    end

    # Send the result
    Dict(:body => result,
         :headers => Dict("Content-Type" => "application/json",
                          "Access-Control-Allow-Origin" => "*"),
         :status => status_code
        )

end)
api_routes = (api_routes..., new_route) # append the route

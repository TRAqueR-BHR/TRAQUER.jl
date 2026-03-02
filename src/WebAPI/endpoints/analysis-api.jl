
# POST /api/analysis/get-analyses-from-patient
function WebAPI.handle_analysis_get_from_patient(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/analysis/get-analyses-from-patient"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    analyses = missing
    error    = nothing
    appuser  = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        patient  = json2entity(Patient, obj["patient"])

        analyses = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                AnalysisResultCtrl.getAnalyses(patient, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(analyses)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/analysis/get-analyses-from-patient", WebAPI.handle_analysis_get_from_patient))


# POST /api/analysis/upsert
function WebAPI.handle_analysis_upsert(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/analysis/upsert"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    analysisResult = missing
    error          = nothing
    appuser        = missing

    status_code = try
        appuser        = req[:params][:appuser]
        cryptPwd       = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj            = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                             JSON.parse(String(req[:data])))
        analysisResult = json2entity(AnalysisResult, obj["analysisResult"])
        analysisRef    = obj["analysisRef"]

        TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                analysisResult = AnalysisResultCtrl.upsert!(
                    analysisResult, analysisRef, cryptPwd, dbconn
                )
                ETLCtrl.processNewlyIntegratedData(dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(analysisResult)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/analysis/upsert", WebAPI.handle_analysis_upsert))


# POST /api/analysis/listing
function WebAPI.handle_analysis_listing(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/analysis/listing"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    query_result = missing
    error        = nothing
    appuser      = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        obj["pageNum"] += 1

        query_result = AnalysisResultCtrl.getAnalysesResultsForListing(
            obj["pageSize"], obj["pageNum"], obj["cols"]
            ; cryptPwd = cryptPwd
        )
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(query_result)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/analysis/listing", WebAPI.handle_analysis_listing))

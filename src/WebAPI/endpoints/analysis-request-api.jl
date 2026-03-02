
# POST /api/analysis-request/save
function WebAPI.handle_analysis_request_save(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/analysis-request/save"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    analysisRequest = missing
    error           = nothing
    appuser         = missing

    status_code = try
        appuser         = req[:params][:appuser]
        cryptPwd        = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj             = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                              JSON.parse(String(req[:data])))
        entity          = json2entity(AnalysisRequest, obj)
        analysisRequest = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                AnalysisRequestCtrl.upsert!(entity, dbconn)
            end
        end
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(analysisRequest)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/analysis-request/save", WebAPI.handle_analysis_request_save))


# POST /api/analysis-request/listing
function WebAPI.handle_analysis_request_listing(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/analysis-request/listing"
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

        query_result = AnalysisRequestCtrl.getAnalysesRequestsForListing(
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
api_routes = (api_routes..., route("/api/analysis-request/listing", WebAPI.handle_analysis_request_listing))


# POST /api/analysis-request/listing-as-xlsx
function WebAPI.handle_analysis_request_listing_as_xlsx(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/analysis-request/listing-as-xlsx"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    fileContent = missing
    error       = nothing
    appuser     = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        obj      = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(
                       JSON.parse(String(req[:data])))
        obj["pageNum"] += 1

        queryResult = AnalysisRequestCtrl.getAnalysesRequestsForListing(
            obj["pageSize"], obj["pageNum"], obj["cols"]
            ; cryptPwd = cryptPwd
        )

        tempFilePath = tempname()
        TRAQUERUtil.serializeDataFrameToExcel(queryResult[:rows], tempFilePath)
        fileContent = read(tempFilePath)
        rm(tempFilePath)
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? fileContent : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end
api_routes = (api_routes..., route("/api/analysis-request/listing-as-xlsx", WebAPI.handle_analysis_request_listing_as_xlsx))

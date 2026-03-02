
# POST /api/analysis-request/listing-as-xlsx
function WebAPI.Endpoints.handle_analysis_request_listing_as_xlsx(req)
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

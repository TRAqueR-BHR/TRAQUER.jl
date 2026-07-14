# POST /api/file-exchange/get-kdf-child-key
function WebAPI.Endpoints.handle_file_exchange_get_kdf_child_key(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/file-exchange/get-kdf-child-key"
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

    result = missing
    error = nothing
    appuser = missing

    status_code = try
        appuser = req[:params][:appuser]

        result = TRAQUERUtil.executeOnBgThread() do
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                FileExchangeCtrl.getKdfChildKey(dbconn)
            end
        end

        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    responseBody = if status_code == 200
        String(JSON.json(result))
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

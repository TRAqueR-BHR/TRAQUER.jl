
# POST /api/misc/name-of-dataset-password-header-for-http-request
function WebAPI.Endpoints.handle_misc_dataset_password_header_name(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "/api/misc/name-of-dataset-password-header-for-http-request"

    nameOfHeader = missing
    error        = nothing

    status_code = try
        nameOfHeader = TRAQUERUtil.getNameOfDatasetPasswordHeaderForHttpRequest()
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(nameOfHeader)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

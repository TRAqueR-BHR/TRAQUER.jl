
# POST /api/task-waiting-for-user-execution/execute-pending-tasks
function WebAPI.Endpoints.handle_task_execute_pending(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    apiURL = "/api/task-waiting-for-user-execution/execute-pending-tasks"
    @info "API $apiURL"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    success = missing
    error   = nothing
    appuser = missing

    status_code = try
        appuser  = req[:params][:appuser]
        cryptPwd = TRAQUERUtil.extractCryptPwdFromHTTPHeader(req)
        if ismissing(cryptPwd)
            error("Missing crypt password")
        end

        # Fire-and-forget: spawn without blocking the response.
        ThreadPools.spawnbg() do
            TaskWaitingForUserExecutionCtrl.executePendingTasks(cryptPwd)
        end

        success = true
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(success)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end


# POST /api/appuser/save
function WebAPI.handle_appuser_save(req)
    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "/api/appuser/save"

    status_code = TRAQUERUtil.initialize_http_response_status_code(req)
    if status_code != 200
        return Dict(:body => String(JSON.json(missing)),
                    :headers => Dict("Content-Type" => "text/plain",
                                     "Access-Control-Allow-Origin" => "*"),
                    :status => status_code)
    end

    appUser = missing
    error   = nothing
    appuser = missing

    status_code = try
        obj    = JSON.parse(String(req[:data]))
        entity = json2Entity(Appuser, obj)
        editor = req[:params][:appuser]
        appuser = editor

        if ismissing(entity.id)
            appUser = Controller.persist!(entity; creator = editor)
        else
            appUser = Controller.update!(entity; editor = editor, updateVectorProps = true)
        end

        appUser = Controller.retrieveOneEntity(Appuser(id = appUser.id), true, true)
        200
    catch e
        TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
        error = e
        500
    end

    result = status_code == 200 ? String(JSON.json(appUser)) : String(JSON.json(string(error)))
    Dict(
        :body    => result,
        :headers => Dict("Content-Type" => "application/json",
                         "Access-Control-Allow-Origin" => "*"),
        :status  => status_code,
    )
end

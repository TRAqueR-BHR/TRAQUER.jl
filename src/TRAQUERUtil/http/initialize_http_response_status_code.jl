function TRAQUERUtil.initialize_http_response_status_code(req)
    # The status code is by default 200 and we look if a filter wants
    #   to overwrite it
    status_code = 200
    if (haskey(req,:params)
        && haskey(req[:params],:status))
         status_code = req[:params][:status]
     end
     return status_code
end

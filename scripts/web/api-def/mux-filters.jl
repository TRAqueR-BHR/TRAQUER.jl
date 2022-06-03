new_filter = Mux.stack(function mux_logger(app, req)
  #println("in logger")
  @info req
  # response = app(req) # this response is not the HttpServer Response - it's just a string, it does not have the :headers, :status, :data fields
  # @show response
  return app(req)
end)
# mux_filters = (mux_filters..., new_filter) # append the filter


new_filter = Mux.stack(function mux_get_appuser_from_jwt(app,req)

  # 'OPTIONS' request must not try to use the JWT
  if req[:method] == "OPTIONS"
    return app(req)
  end

  # If the api does need authentication, exit here
  # Transformation des clés en minuscules pour fonctionnement dans tous les cas
  # Exemple : VB envoie systématiquement la clé "Authorization" et pas "authorization"
  headers_dict = Dict(zip(lowercase.(getproperty.(req[:headers], :first)),
                          getproperty.(req[:headers], :second)))

  # @info "headers_dict" headers_dict
  # @info "req[:headers]" req[:headers]
  #
  # @info collect(keys(headers_dict))
  #
  # @info "haskey(headers_dict,Authorization)1" haskey(headers_dict,"Authorization")

  # The request may not have a ':param' key
  if !haskey(req,:params)
    req[:params] = Dict{Any,Any}()
  end

  # Initialize the :appuser at missing
  req[:params][:appuser] = missing


  if (req[:path] in apis_paths_wo_jwt ||
        (req[:path][1] == "file-upload" && req[:path][2] == "get-pdf"))
    @info  "[$(string(req[:uri]))] does not require JWT authentication"
    return app(req)
  end

  # @info "Checking JWT and find an existing user"

  # If the header contains the 'Authorization' field we check its validity and
  #  try to find the corresponding user
  if haskey(headers_dict,"authorization")
    jwt_str = headers_dict["authorization"]
    jwt_str = replace(jwt_str, "Bearer" => "")
    jwt_str = replace(jwt_str, " " => "")
    jwt = JWT(; jwt = jwt_str)
    validate!(jwt, jwtkeyset, jwtkeyid)

    if !isvalid(jwt)
      @info "Invalid credentials"
      req[:params][:status] = 401
      req[:params][:message] = "Invalid credentials"
    else
      # Retrieve the user from the JWT
      jwt_dict = JWTs.claims(jwt)
      req[:params][:appuser] = try
         Controller.retrieveOneEntity(
                        Appuser(login = jwt_dict["login"]),
                        true, # complex props
                        true # includeVectorProps
                      )
       catch e
         # rethrow(e)
         message = TRAQUERUtil.formatExceptionAndStackTrace(e,
                                                  stacktrace(catch_backtrace()))
         @warn message
         missing
       end
    end # ENDOF !isvalid(jwt)

  else
    @info "No Authorization header"
    req[:params][:status] = 401
    req[:params][:message] = "No Authorization header"
    # throw(DomainError("This API is protected"))

  end # ENDOF haskey(headers_dict,"Authorization")

  return app(req)

end)
mux_filters = (mux_filters..., new_filter) # append the filter

# DOES NOT WORK, need to be put in every functions api
# function access_control_allow_origin(app, req)
#   # @show req
#   return app(req)
# end

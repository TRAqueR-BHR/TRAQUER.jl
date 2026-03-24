include("_const.jl")
include("utils/__imp.jl")
include("buildApp.jl")
include("serve.jl")

# ──────────────────────────────────────────────────────────────────────────────
# WebAPI implementation
# Mirrors the logic previously found in scripts/web/web-api-definition.jl but
# encapsulated inside the TRAQUER.WebAPI submodule.
# ──────────────────────────────────────────────────────────────────────────────

# # JWT key set – loaded once when the module is first used
# const _jwtkeyset = Ref{Union{Nothing,JWKSet}}(nothing)
# const _jwtkeyid  = Ref{Union{Nothing,String}}(nothing)

# function _ensure_jwt_keyset()
#     if isnothing(_jwtkeyset[])
#         ks = JWKSet(TRAQUERUtil.getConf("security", "jwt_signing_keys_uri"))
#         refresh!(ks)
#         _jwtkeyset[] = ks
#         _jwtkeyid[]  = first(first(ks.keys))
#     end
#     return _jwtkeyset[], _jwtkeyid[]
# end

# # Paths that do NOT require JWT authentication.
# # Each entry is a vector of path segments (the way Mux splits them).
# const apis_paths_wo_jwt = [
#     ["authenticate"],
#     ["misc", "get-current-frontend-version"],
#     ["ws_io"],
#     ["api", "hello"],   # hello-world is public
# ]

# ── Helpers ───────────────────────────────────────────────────────────────────

# function respFor_OPTIONS_req()
#     accessControlAllowHeaders  = "origin, content-type, accept, authorization"
#     accessControlAllowHeaders *= ", $(TRAQUERUtil.getCryptPwdHttpHeaderKey())"
#     accessControlAllowHeaders *= ", browser-timezone"
#     accessControlAllowHeaders *= ", file_name"
#     accessControlAllowHeaders *= ", exam_id"
#     accessControlAllowHeaders *= ", exam_year"

#     Dict(
#         :headers => Dict(
#             "Access-Control-Allow-Origin"      => "*",
#             "Access-Control-Allow-Headers"     => accessControlAllowHeaders,
#             "Access-Control-Allow-Credentials" => "true",
#             "Access-Control-Allow-Methods"     => "GET, POST, PUT, DELETE, OPTIONS, HEAD",
#         ),
#     )
# end

# ── Route / filter accumulation ───────────────────────────────────────────────

# # Mux filter: JWT authentication
# let
#     new_filter = Mux.stack(function mux_get_appuser_from_jwt(app, req)

#         if req[:method] == "OPTIONS"
#             return app(req)
#         end

#         headers_dict = Dict(
#             zip(
#                 lowercase.(getproperty.(req[:headers], :first)),
#                 getproperty.(req[:headers], :second),
#             ),
#         )

#         if !haskey(req, :params)
#             req[:params] = Dict{Any,Any}()
#         end
#         req[:params][:appuser] = missing

#         if (req[:path] in apis_paths_wo_jwt ||
#             (length(req[:path]) >= 2 && req[:path][1] == "file-upload" &&
#              req[:path][2] == "get-pdf"))
#             @info "[$(string(req[:uri]))] does not require JWT authentication"
#             return app(req)
#         end

#         if haskey(headers_dict, "browser-timezone")
#             req[:params][:browserTimezone] = TimeZones.TimeZone(
#                 headers_dict["browser-timezone"],
#                 TimeZones.Class(:FIXED) | TimeZones.Class(:STANDARD) | TimeZones.Class(:LEGACY),
#             )
#         end

#         if haskey(headers_dict, "authorization")
#             jwtkeyset, jwtkeyid = _ensure_jwt_keyset()
#             jwt_str = replace(replace(headers_dict["authorization"], "Bearer" => ""), " " => "")
#             jwt = JWT(; jwt = jwt_str)
#             validate!(jwt, jwtkeyset, jwtkeyid)

#             if !isvalid(jwt)
#                 @info "Invalid credentials"
#                 req[:params][:status]  = 401
#                 req[:params][:message] = "Invalid credentials"
#             else
#                 jwt_dict = JWTs.claims(jwt)
#                 req[:params][:appuser] = try
#                     Controller.retrieveOneEntity(
#                         Appuser(login = jwt_dict["login"]),
#                         true,
#                         true,
#                     )
#                 catch e
#                     @warn TRAQUERUtil.formatExceptionAndStackTrace(e, stacktrace(catch_backtrace()))
#                     missing
#                 end
#             end
#         else
#             @info "No Authorization header"
#             req[:params][:status]  = 401
#             req[:params][:message] = "No Authorization header"
#         end

#         return app(req)
#     end)
#     global mux_filters = (mux_filters..., new_filter)
# end



# ── Public API ────────────────────────────────────────────────────────────────

# function WebAPI.build_app()
#     @app web_api = (
#         Mux.defaults,
#         mux_filters...,
#         api_routes...,
#         Mux.notfound(),
#     )
#     return web_api
# end

# function WebAPI.serve(host = Mux.localhost, port = 8095; reuseaddr = false)
#     app = WebAPI.build_app()
#     @info "TRAQUER.WebAPI: starting HTTP server on $(host):$(port)"
#     Mux.serve(app, host, port; reuseaddr = reuseaddr)
# end

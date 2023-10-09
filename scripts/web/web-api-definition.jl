include("web-socket-definition.jl")

using Mux
using JSON
using HTTP
using Serialization
using JWTs

jwtkeyset = JWKSet(getConf("security","jwt_signing_keys_uri"));
refresh!(jwtkeyset)
jwtkeyid = first(first(jwtkeyset.keys))

# Set the apis that will not be checked for a valid JWT
# This is a vector of strings vectors because we compare paths and not URIs
# eg: URIs '/unsecure/authenticate/' and  '/unsecure/authenticate' will have the
#     same following path: ["unsecure","authenticate"]
apis_paths_wo_jwt = [
  ["authenticate"],
  ["misc","get-current-frontend-version"],
  ["ws_io"],
]

# Initialize the tuple of routes
api_routes = ()
mux_filters = ()
# Loop over the files in "/scripts/web/api-def/" to populate the  api routes and the mux filters
folderFor_web_src = pwd() * "/scripts/web/api-def/"
for f in filter(x -> occursin(r".jl$", x),
                readdir(pwd() * "/scripts/web/api-def"))
  # println(f)
  include(folderFor_web_src * f)
end

function respFor_OPTIONS_req()

  accessControlAllowHeaders = "origin, content-type, accept, authorization"
  accessControlAllowHeaders *= ", $(TRAQUERUtil.getCryptPwdHttpHeaderKey())"
  accessControlAllowHeaders *= ", browser-timezone"
  accessControlAllowHeaders *= ", file_name"
  accessControlAllowHeaders *= ", exam_id"
  accessControlAllowHeaders *= ", exam_year"


  Dict(
     :headers => Dict("Access-Control-Allow-Origin" => "*" ,
                      "Access-Control-Allow-Headers" => accessControlAllowHeaders,
                      "Access-Control-Allow-Credentials" => "true",
                      "Access-Control-Allow-Methods" => "GET, POST, PUT, DELETE, OPTIONS, HEAD"
                  )
      )

end

@app web_api = (
  Mux.defaults,
  mux_filters...,
  api_routes...,
  # stack(access_control_allow_origin),

  # eg.
  # curl -d '{"key1":"value1", "key2":"value2"}' -H "Content-Type: application/json" -X POST http://localhost:8082/testjson/process/
  route("/testjson/process/", req -> begin
    obj = JSON.parse(String(req[:data]))

    @show req

    Dict(:body => String(JSON.json(obj)),
         :headers => Dict("Content-Type" => "application/json")
         )
  end),

  Mux.notfound())

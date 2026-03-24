# JWT key set – loaded once when the module is first used
const WebAPI._jwtkeyset = Ref{Union{Nothing,JWKSet}}(nothing)
const WebAPI._jwtkeyid  = Ref{Union{Nothing,String}}(nothing)

# Paths that do NOT require JWT authentication.
# Each entry is a vector of path segments (the way Mux splits them).
const WebAPI.apis_paths_wo_jwt = [
    ["authenticate"],
    ["misc", "get-current-frontend-version"],
    ["ws_io"],
    ["api", "hello"],   # hello-world is public
]

#
# Hello-world endpoint – used to verify that the WebAPI submodule is wired up correctly.
#
# curl http://localhost:8095/api/hello
#
function WebAPI.handle_hello(req)

    req[:method] == "OPTIONS" && return WebAPI._respFor_OPTIONS_req()

    @info "API /api/hello"

    Dict(
        :body    => String(JSON.json(Dict("message" => "Hello! from TRAQUER.WebAPI!"))),
        :status  => 200,
        :headers => Dict(
            "Content-Type"                => "application/json",
            "Access-Control-Allow-Origin" => "*",
        ),
    )
end

api_routes = (api_routes..., route("/api/hello", WebAPI.handle_hello))

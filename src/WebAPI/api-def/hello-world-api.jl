#
# Hello-world endpoint – used to verify that the WebAPI submodule is wired up correctly.
#
# curl http://localhost:8095/api/hello
#
new_route = route("/api/hello", req -> begin

    if req[:method] == "OPTIONS"
        return respFor_OPTIONS_req()
    end

    @info "API /api/hello"

    Dict(
        :body    => String(JSON.json(Dict("message" => "Hello from TRAQUER.WebAPI!"))),
        :status  => 200,
        :headers => Dict(
            "Content-Type"                => "application/json",
            "Access-Control-Allow-Origin" => "*",
        ),
    )
end)
api_routes = (api_routes..., new_route)

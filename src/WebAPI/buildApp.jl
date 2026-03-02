function WebAPI.build_app()

    routes = (route("/api/hello", WebAPI.handle_hello),)

    @app web_api = (
        Mux.defaults,
        mux_filters...,
        routes...,
        Mux.notfound(),
    )
    return web_api
end

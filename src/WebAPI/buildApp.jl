function WebAPI.build_app()
    @app web_api = (
        Mux.defaults,
        mux_filters...,
        api_routes...,
        Mux.notfound(),
    )
    return web_api
end

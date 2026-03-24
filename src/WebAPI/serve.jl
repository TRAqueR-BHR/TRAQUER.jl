function WebAPI.serve(host = Mux.localhost, port = 8095; reuseaddr = false)
    app = WebAPI.build_app()
    @info "TRAQUER.WebAPI: starting HTTP server on $(host):$(port)"
    Mux.serve(app, host, port; reuseaddr = reuseaddr)
end

include("utils/__def.jl")
include("filters/__def.jl")
include("endpoints/__def.jl")

"""
    build_app()

Assemble and return the Mux application with all registered routes and filters.
"""
function build_app end

"""
    serve(host=Mux.localhost, port=8095; reuseaddr=false)

Start the HTTP server on `host:port`.
"""
function serve end

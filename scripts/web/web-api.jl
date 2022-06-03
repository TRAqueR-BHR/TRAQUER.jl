using Distributed
include("../prerequisite.jl")

# If we find in the configuration that we want more procs, add some
if haskey(ENV,"TRAQUER_ADDITIONAL_PROCS")
  @info "TRAQUER_ADDITIONAL_PROCS[$(ENV["TRAQUER_ADDITIONAL_PROCS"])]"
  additionalProcs=parse(Int,ENV["TRAQUER_ADDITIONAL_PROCS"])
  if additionalProcs > 0
    addprocs(additionalProcs)
  end
end

# Run all the required 'using' again now that we have all the workers
include("../prerequisite.jl")

@everywhere using Mux, HTTP

# The loggers need to be declared once the modules are loaded because they have
#   a reference to them
@everywhere include("../logging/loggers.jl")

# Warmup workers
# if TRAQUERUtil.blindBakeIsRequired()
#   include("../warmup/warmup.jl")
# end

# Reference:
# https://github.com/JuliaWeb/JuliaWebAPI.jl/issues/73

# Source the following file when it has been changed or that something in the
#   module used by the API has changed.
# NOTE: Do not restart Mux.serve()

@everywhere include("web-api-definition.jl")

# WebSocket server
@everywhere function websocket_example(x)
    sock = x[:socket]
    while !eof(sock)
        str = String(read(sock))
        println("Received data: " * str)
        write(sock, "Hey, I've received " * str)
    end
end

@app web_socket = (
    Mux.wdefaults,
    route("/ws_io", websocket_example),
    Mux.wclose,
    Mux.notfound()
)

Mux.serve(web_api, web_socket, Mux.localhost, 8095
            ;reuseaddr = true)

# https://richardanaya.medium.com/how-to-create-a-multi-threaded-http-server-in-julia-ca12dca09c35
# Starting an HTTP server on several worker doesnt do anything (apart from creating warn messages )
#   for i in 1:nprocs()
#     # Start the server (only once per julia session)
#     @spawnat i Mux.serve(web_api,w, Mux.localhost, 8095
#              ;reuseaddr = true)
#   end

# Mux.serve(web_api, Mux.localhost, 8082
#          ;reuseaddr = true)

# The following is commented out because we want to have access to the REPL
# Base.JLOptions().isinteractive == 0 && wait()

# Uncomment if needed
# TRAQUER.startScheduler()

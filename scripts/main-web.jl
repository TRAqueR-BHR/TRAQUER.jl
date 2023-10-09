include("prerequisite.jl")

@everywhere using Mux, HTTP

# The loggers need to be declared once the modules are loaded because they have
#   a reference to them
# We had to comment out this because it was causing issues when running TRAQUER on several workers
@everywhere include("logging/loggers.jl")

# Warmup workers
# if TRAQUERUtil.blindBakeIsRequired()
#   include("../warmup/warmup.jl")
# end

# Reference:
# https://github.com/JuliaWeb/JuliaWebAPI.jl/issues/73

# Source the following file when it has been changed or that something in the
#   module used by the API has changed.
# NOTE: Do not restart Mux.serve()

@everywhere include("web/web-api-definition.jl")

Mux.serve(
    web_api, Mux.localhost, 8095
    ;reuseaddr = false
)

# The following is commented out because we want to have access to the REPL
# Base.JLOptions().isinteractive == 0 && wait()

TRAQUER.startScheduler()

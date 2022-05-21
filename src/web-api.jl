using Distributed

# If we find in the configuration that we want more procs, add some
if haskey(ENV,"TRAQUER_ADDITIONAL_PROCS")
  @info "TRAQUER_ADDITIONAL_PROCS[$(ENV["TRAQUER_ADDITIONAL_PROCS"])]"
  additionalProcs=parse(Int,ENV["TRAQUER_ADDITIONAL_PROCS"])
  if additionalProcs > 0
    addprocs(additionalProcs)
  end
end

@everywhere using Pkg
@everywhere Pkg.activate(".")
@everywhere using Revise


# DEPRECATED
# addprocs(Sys.CPU_THREADS - 1) # Add the number of processors minus one (for the
#                               #  current process)

@everywhere using Distributed # Add Distributed to all processes because we
                              #   want to use Distributed.myid() in the processes


@everywhere push!(LOAD_PATH, ENV["PostgresORM_PATH"])

@everywhere using BlindBake
@everywhere using Mux, HTTP, UUIDs
# @everywhere using HttpCommon

# Overwrite some packages
# include("package-overwrite/HTTP-overwrite.jl")
# For handling file upload in Mux
@everywhere include("package-overwrite/Mux-overwrite.jl")
@everywhere include("package-overwrite/BlindBake-overwrite.jl")

# Run all the required 'using'
@everywhere include("using.jl")

# ################# #
# BlindBake - BEGIN #
# ################# #
if TRAQUERUtil.blindBakeIsRequired()
  error("Not implemented yet")
  # Temporarily change the configuration
  # MerchmgtUtil.overwriteConfForPrecompilation()
  # BlindBake.invokeMethodsOfModule(Merchmgt.Controller.AppUserDAO)
  # include("precompile.jl")

  # Restore configuration
  # MerchmgtUtil.restoreConfAfterPrecompilation()
end
# ################# #
# BlindBake - ENDOF #
# ################# #

# The loggers need to be declared once the modules are loaded because they have
#   a reference to them
@everywhere include("logging/loggers.jl")
# logger = createLogger() # see logging/loggers.jl for other values


with_logger(to_file_and_console_logger) do

    @show "test log"

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

    @app w = (
        Mux.wdefaults,
        route("/ws_io", websocket_example),
        Mux.wclose,
        Mux.notfound()
    );


    Mux.serve(web_api,w, Mux.localhost, 8093 ;reuseaddr = true)

    # Mux.serve(web_api, 8084)
    # Mux.serve(Merchm  gt.WebApi.web_api, 8082) # works but Revise does not work on it

    # The following is commented out because we want to have access to the REPL
    # Base.JLOptions().isinteractive == 0 && wait()

end # with_logger


# TRAQUER.startScheduler()

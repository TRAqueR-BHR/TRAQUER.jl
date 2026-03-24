include("_prerequisite.jl")
TRAQUER.WebAPI.serve()

# The following is commented out because we want to have access to the REPL
# Base.JLOptions().isinteractive == 0 && wait()

TRAQUER.startScheduler()

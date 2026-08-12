# NOTE: We expect the working directory to be at the root of the project
#       eg. If the project is at /home/vlaugier/CODE/TRAQUER.jl then
#           pwd() should return /home/vlaugier/CODE/TRAQUER.jl
using Distributed

# Safety net in case the workers are not cleaned up properly. This can happen if the main
# Julia process is killed with SIGKILL or if the workers are orphaned for some reason.
run(`./scripts/cleanup-orphaned-julia-processes.sh`)

include("add-procs.jl")

@everywhere using Pkg
@everywhere Pkg.activate(".") # needed on workers > 1
@everywhere using Revise

include("./using.jl")

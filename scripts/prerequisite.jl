# NOTE: We expect the working directory to be at the root of the project
#       eg. If the project is at /home/vlaugier/CODE/Medilegist.jl then
#           pwd() should return /home/vlaugier/CODE/Medilegist.jl
using Distributed

# Need to load modules in worker 1 first (before the other workers), if not it doesnt work
include("./using.jl")
sleep(1)

include("add-procs.jl")

@everywhere using Pkg
@everywhere Pkg.activate(".") # needed on workers > 1
@everywhere using Revise

@everywhere include("./using.jl")

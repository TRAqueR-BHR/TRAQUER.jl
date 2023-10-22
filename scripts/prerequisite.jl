# NOTE: We expect the working directory to be at the root of the project
#       eg. If the project is at /home/vlaugier/CODE/TRAQUER.jl then
#           pwd() should return /home/vlaugier/CODE/TRAQUER.jl
using Distributed

include("add-procs.jl")

@everywhere using Pkg
@everywhere Pkg.activate(".") # needed on workers > 1
@everywhere using Revise

include("./using.jl")

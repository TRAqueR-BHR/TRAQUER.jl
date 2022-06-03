# NOTE: We expect the working directory to be at the root of the project
#       eg. If the project is at /home/vlaugier/CODE/Medilegist.jl then
#           pwd() should return /home/vlaugier/CODE/Medilegist.jl
using Distributed
@everywhere using Pkg
@everywhere Pkg.activate(".") # needed on workers > 1
@everywhere using Revise


# Uncomment this and remove PostgresORM from Project.toml when you want
#   to work on PostgresORM
# @everywhere push!(LOAD_PATH, ENV["PostgresORM_PATH"])

include("./using.jl")

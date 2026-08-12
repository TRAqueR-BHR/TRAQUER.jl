# We want as many procs as
using Distributed

# We want this to be explicitely set in the configuration
if !haskey(ENV,"ADDITIONAL_PROCS_NUMBER")
    error(
        "Missing environment variable[ADDITIONAL_PROCS_NUMBER]."
        *" You can add it in ~/.julia/config/startup.jl"
    )
end

numberOfProcsToBeAdded = parse(Int, ENV["ADDITIONAL_PROCS_NUMBER"])
if numberOfProcsToBeAdded > 0 && nprocs() < numberOfProcsToBeAdded + 1
    @info "Adding $numberOfProcsToBeAdded workers"
    addprocs(numberOfProcsToBeAdded)
else
    @info "Required number of workers ($numberOfProcsToBeAdded) already present. No additional workers added."
end

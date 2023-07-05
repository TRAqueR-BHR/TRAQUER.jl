# We want as many procs as
using Distributed

# We want this to be explicitely set in the configuration
if !haskey(ENV,"TRAQUER_ADD_ADDITIONAL_PROCS")
    error(
        "Missing environment variable[TRAQUER_ADD_ADDITIONAL_PROCS]."
        *" You can add it in ~/.julia/config/startup.jl"
    )
end

addAdditionalWorkers = parse(Bool,ENV["TRAQUER_ADD_ADDITIONAL_PROCS"])
if addAdditionalWorkers
    numberOfProcsToBeAdded = length(Sys.cpu_info())  - nprocs()
    @info "Adding $numberOfProcsToBeAdded workers"
    if numberOfProcsToBeAdded > 0
        addprocs(numberOfProcsToBeAdded)
    end
end

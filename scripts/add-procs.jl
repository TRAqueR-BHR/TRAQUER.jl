# We want as many procs as
numberOfProcsToBeAdded = Sys.CPU_THREADS - nprocs()
if numberOfProcsToBeAdded > 0
    addprocs(numberOfProcsToBeAdded)
end

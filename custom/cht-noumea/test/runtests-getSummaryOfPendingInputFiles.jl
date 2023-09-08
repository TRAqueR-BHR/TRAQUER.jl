include("prerequisite.jl")

@testset "Test Custom.getSummaryOfPendingInputFiles" begin
    Custom.getSummaryOfPendingInputFiles("/home/traquer/DATA/pending")
end

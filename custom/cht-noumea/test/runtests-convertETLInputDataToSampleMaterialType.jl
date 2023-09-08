include("prerequisite.jl")

@runtests "Test Custom.convertETLInputDataToSampleMaterialType" begin
    Custom.convertETLInputDataToSampleMaterialType("ABC") == SampleMaterialType.purulent_collection
end

include("prerequisite.jl")

@testset "Test Custom.getBasicInformationAboutStaysInputFile" begin
    Custom.getBasicInformationAboutStaysInputFile("/home/traquer/DATA/pending/dxcare-3mois.csv")
end

include("../../../test/runtests-prerequisite.jl")

@testset "Test Custom.getBasicInformationAboutAnalysesInputFile" begin
    Custom.getBasicInformationAboutAnalysesInputFile("/home/traquer/DATA/pending/inlog-3mois.csv")
end

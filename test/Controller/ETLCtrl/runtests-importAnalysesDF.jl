include("__prerequisite.jl")

@testset "Test ETLCtrl.importAnalysesDF" begin

    # This test consist
    xmlPath = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-fhir SALIOU.xml"
    df = ETLCtrl.FHIR.parseXMLToAnalysesDF(xmlPath)

    ETLCtrl.importAnalysesDF(df, getDefaultEncryptionStr())


end

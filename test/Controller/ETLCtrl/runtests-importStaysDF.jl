include("__prerequisite.jl")

@testset "Test ETLCtrl.importStaysDF" begin

    # This test consist
    xmlPath = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-fhir SALIOU.xml"
    df = ETLCtrl.FHIR.getStaysDataFrameFromXML(xmlOutputFilePath)

    ETLCtrl.importStaysDF(df, getDefaultEncryptionStr())


end

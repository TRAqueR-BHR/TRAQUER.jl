include("__prerequisite.jl")

@testset "Test ETLCtrl.importStaysDF" begin

    # This test consist
    xmlPath = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-fhir SALIOU.xml"
    df = ETLCtrl.FHIR.parseXMLToStaysDF(xmlPath)

    ETLCtrl.importStaysDF(df, _TestUtils.getDefaultEncryptionStr())


end


@testset "Test ETLCtrl.importStaysDF with random data" begin

    # This test consist
    namedTuple = _TestUtils.buildInputDataFrames(nbPatients = 20)

    ETLCtrl.importStaysDF(namedTuple.stays, _TestUtils.getDefaultEncryptionStr())


end

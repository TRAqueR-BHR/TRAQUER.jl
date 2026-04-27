include("__prerequisite.jl")

@testset "Test ETLCtrl.FHIR.checkAllReferencesAreDeclared" begin

    xmlFilePath = "test/Controller/ETLCtrl/FHIR/assets/bundle_fhir_2026-03-10.xml"
    xmlDoc = ETLCtrl.FHIR.loadXMLFile(xmlFilePath)

    # Test 1: A complete and valid bundle should return no undeclared references
    undeclared = ETLCtrl.FHIR.checkAllReferencesAreDeclared(xmlDoc)
    @test isempty(undeclared)

end

@testset "Test ETLCtrl.FHIR.checkAllReferencesAreDeclared - missing Location" begin

    xmlFilePath = "test/Controller/ETLCtrl/FHIR/assets/bundle_fhir_missing_location.xml"
    xmlDoc = ETLCtrl.FHIR.loadXMLFile(xmlFilePath)

    # Test 2: A bundle where an Encounter references a Location not declared in the bundle
    undeclared = ETLCtrl.FHIR.checkAllReferencesAreDeclared(xmlDoc)
    @test length(undeclared) == 1
    @test "Location/loc-MISSING" in undeclared

end

@testset "Test ETLCtrl.FHIR.checkAllReferencesAreDeclared - for SALIOU file" begin

    xmlFilePath = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-fhir SALIOU.xml"
    xmlDoc = ETLCtrl.FHIR.loadXMLFile(xmlFilePath)

    undeclared = ETLCtrl.FHIR.checkAllReferencesAreDeclared(xmlDoc)

end

@testset "Test ETLCtrl.FHIR.checkAllReferencesAreDeclared - for README example file" begin

    xmlFilePath = "READMEs/HL7-FHIR/examples/scenario1-fhir-r5.xml"
    xmlDoc = ETLCtrl.FHIR.loadXMLFile(xmlFilePath)

    undeclared = ETLCtrl.FHIR.checkAllReferencesAreDeclared(xmlDoc)

end

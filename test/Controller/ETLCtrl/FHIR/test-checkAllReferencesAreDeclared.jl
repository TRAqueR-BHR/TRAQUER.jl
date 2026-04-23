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

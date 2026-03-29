include("__prerequisite.jl")

@testset "Test ETLCtrl.FHIR.checkReferenceIsDeclared" begin

    xmlFilePath = "test/Controller/ETLCtrl/FHIR/assets/bundle_fhir_2026-03-10.xml"
    xmlDoc = ETLCtrl.FHIR.loadXMLFile(xmlFilePath)

    # Test 1: A Location resource that exists in the bundle
    @test ETLCtrl.FHIR.checkReferenceIsDeclared("Location/loc-CARDIO", xmlDoc) == true

    # Test 2: A Location resource that does NOT exist in the bundle
    @test ETLCtrl.FHIR.checkReferenceIsDeclared("Location/loc-UNKNOWN", xmlDoc) == false

    # Test 3: A Patient resource that exists in the bundle
    @test ETLCtrl.FHIR.checkReferenceIsDeclared("Patient/patient-406284028", xmlDoc) == true

    # Test 4: An Organization resource that exists in the bundle
    @test ETLCtrl.FHIR.checkReferenceIsDeclared("Organization/org-29000", xmlDoc) == true

    # Test 5: A resource type that does not exist at all in the bundle
    @test ETLCtrl.FHIR.checkReferenceIsDeclared("Medication/med-999", xmlDoc) == false

end

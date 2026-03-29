include("__prerequisite.jl")

@testset "Test ETLCtrl.FHIR.validateAgainstSchema with valid XML file" begin
    xmlFilePath = "test/Controller/ETLCtrl/FHIR/assets/bundle_fhir_2026-03-10.xml"
    xsdFilePath = "test/Controller/ETLCtrl/FHIR/assets/FHIR-r5/fhir-r5-single.xsd"
    isValid, errorLines = ETLCtrl.FHIR.validateAgainstSchema(xmlFilePath, xsdFilePath)
    @test isValid == true
    @test isempty(errorLines)
end

@testset "Test ETLCtrl.FHIR.validateAgainstSchema with invalid XML file" begin
    xmlFilePath = "test/Controller/ETLCtrl/FHIR/assets/invalid.xml"
    xsdFilePath = "test/Controller/ETLCtrl/FHIR/assets/FHIR-r5/fhir-r5-single.xsd"
    isValid, errorLines = ETLCtrl.FHIR.validateAgainstSchema(xmlFilePath, xsdFilePath)
    # @info "Validation errors:" errorLines
    for line in errorLines
        @info line
    end
    @test isValid == false
    @test !isempty(errorLines)
end

include("__prerequisite.jl")

@testset "Test ETLCtrl.FHIR.validateAgainstSchema with valid XML file" begin
    xmlFilePath = "test/Controller/ETLCtrl/FHIR/assets/bundle_fhir_2026-03-10.xml"
    xsdFilePath = "test/Controller/ETLCtrl/FHIR/assets/FHIR-r5/fhir-r5-single.xsd"
    isValid, errors = ETLCtrl.FHIR.validateAgainstSchema(xmlFilePath, xsdFilePath)
    @test isValid == true
    @test isempty(errors)
end

@testset "Test ETLCtrl.FHIR.validateAgainstSchema with invalid XML file" begin
    xmlFilePath = "test/Controller/ETLCtrl/FHIR/assets/invalid.xml"
    xsdFilePath = "test/Controller/ETLCtrl/FHIR/assets/FHIR-r5/fhir-r5-single.xsd"
    isValid, errors = ETLCtrl.FHIR.validateAgainstSchema(xmlFilePath, xsdFilePath)
    for e in errors
        @info "FHIR validation error" e.fileName e.lineNumber e.errorMessage
    end
    @test isValid == false
    @test !isempty(errors)
    @test all(e -> !ismissing(e.lineNumber), errors)
    @test all(e -> !ismissing(e.fileName), errors)
end

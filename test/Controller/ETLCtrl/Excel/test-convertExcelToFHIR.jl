include("__prerequisite.jl")

@testset "Test ETLCtrl.Excel.convertExcelToFHIR" begin
    # Prepare test data
    staysExcelFilePath = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-stays SALIOU.XLSX"
    analysisExcelFilePath = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/demo-analyses SALIOU.XLSX"
    xmlOutputFilePath = "tmp/expected_fhir.xml"

    # Call the function to be tested
    fhir_output = ETLCtrl.Excel.convertExcelToFHIR(staysExcelFilePath, analysisExcelFilePath, xmlOutputFilePath)

end

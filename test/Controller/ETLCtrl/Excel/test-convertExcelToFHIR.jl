include("__prerequisite.jl")

@testset "Test ETLCtrl.Excel.convertExcelToFHIR" begin

    rootDir = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/"

    # Declare the input stays and analyses Excel file paths and the output XML file path
    staysExcelFilePath = joinpath(rootDir, "demo-stays SALIOU.XLSX")
    analysisExcelFilePath = joinpath(rootDir, "demo-analyses SALIOU.XLSX")
    xmlOutputFilePath = joinpath(rootDir, "demo-fhir SALIOU.xml")
    fhir_output = ETLCtrl.Excel.convertExcelToFHIR(
        staysExcelFilePath, analysisExcelFilePath, xmlOutputFilePath
    )

end

include("__prerequisite.jl")

@testset "Test ETLCtrl.FHIR.formatXMLFile" begin
    inputFilePath = "test/Controller/ETLCtrl/FHIR/assets/unformatted.xml"
    outputFilePath = "tmp/formatted.xml"

    # Call the function to format the XML file
    ETLCtrl.FHIR.formatXMLFile(inputFilePath, outputFilePath)

    # Check if the output file exists
    @test isfile(outputFilePath)

    # Optionally, you can read the contents of the formatted file and check if it's properly formatted
    formattedContent = read(outputFilePath, String)
    @test occursin("\n", formattedContent)  # Check if there are newlines in the formatted content
end

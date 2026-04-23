include("__prerequisite.jl")

@testset "Test ETLCtrl.FHIR.loadXMLFile" begin

    # Test 1: Load a valid XML file
    xml_file_path = "test/Controller/ETLCtrl/FHIR/assets/bundle_fhir_2026-03-10.xml"
    result = ETLCtrl.FHIR.loadXMLFile(xml_file_path)
    @info typeof(result)

end

include("__prerequisite.jl")

@testset "Test ETLCtrl.FHIR.getAnalysesDataFrameFromXML" begin


    # This test consists in generating the FHIR XML file from the stays and analyses Excel
    # files, then using the generated XML file for `getAnalysesDataFrameFromXML` and checking
    # if the output DataFrame is the same as the one loaded from the analyses Excel file

    rootDir = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/"

    # Declare the input stays and analyses Excel file paths and the output XML file path
    staysExcelFilePath    = joinpath(rootDir, "demo-stays SALIOU.XLSX")
    analysisExcelFilePath = joinpath(rootDir, "demo-analyses SALIOU.XLSX")
    xmlOutputFilePath     = joinpath(rootDir, "demo-fhir SALIOU.xml")
    fhir_output = ETLCtrl.Excel.convertExcelToFHIR(
        staysExcelFilePath, analysisExcelFilePath, xmlOutputFilePath
    )

    df = ETLCtrl.FHIR.getAnalysesDataFrameFromXML(xmlOutputFilePath)


    srcDF = DataFrame(XLSX.readtable(analysisExcelFilePath, 1))

    # Convert patient_ref to string to ensure the same type as the one returned by getAnalysesDataFrameFromXML
    srcDF.patient_ref = string.(srcDF.patient_ref)

    # Convert analysis_ref to string
    srcDF.analysis_ref = string.(srcDF.analysis_ref)

    # Convert request_time and result_time from Date/DateTime to ZonedDateTime
    srcDF.request_time = ZonedDateTime.(srcDF.request_time, TRAQUERUtil.getTimeZone())
    srcDF.result_time  = passmissing(ZonedDateTime).(srcDF.result_time, TRAQUERUtil.getTimeZone())


    # Order both dataframes by patient_ref and analysis_ref to ensure the same order of rows
    df    = sort(df,    [:patient_ref, :analysis_ref])
    srcDF = sort(srcDF, [:patient_ref, :analysis_ref])

    # Check number of rows match
    @test DataFrames.nrow(df) == DataFrames.nrow(srcDF)

    # List of columns to compare
    colsOfInterest = [
        :patient_ref,
        :analysis_ref,
        :status,
        :request_time,
        :result_time,
        :sample,
        :request_type,
        :result,
    ]

    # Check that both dataframes match for the columns of interest
    for (i, r) in enumerate(eachrow(srcDF))
        for col in colsOfInterest
            errorContext = "patient_ref=$(r.patient_ref), analysis_ref=$(r.analysis_ref), " *
                "column = $col: " *
                "excel value = $(srcDF[i,col]) of type $(typeof(srcDF[i,col])) vs " *
                "xml value = $(df[i,col]) of type $(typeof(df[i,col]))"
            _match = try
                if !isequal(srcDF[i,col], df[i,col])
                    false
                else
                    true
                end
            catch e
                error("Error comparing row for $errorContext: $e")
            end
            if !_match
                error("Mismatch for $errorContext")
            end
        end
    end


end

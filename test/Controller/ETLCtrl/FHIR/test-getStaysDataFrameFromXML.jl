include("__prerequisite.jl")

@testset "Test ETLCtrl.FHIR.getStaysDataFrameFromXML" begin


    # This test consist in generating the FHIR XML file from the stays and analyses Excel
    # files, then using the generated XML file for `getStaysDataFrameFromXML` and check
    # if the output DataFrame is the same as the one loaded from the stays Excel file

    rootDir = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/"

    # Declare the input stays and analyses Excel file paths and the output XML file path
    staysExcelFilePath = joinpath(rootDir, "demo-stays SALIOU.XLSX")
    analysisExcelFilePath = joinpath(rootDir, "demo-analyses SALIOU.XLSX")
    xmlOutputFilePath = joinpath(rootDir, "demo-fhir SALIOU.xml")
    fhir_output = ETLCtrl.Excel.convertExcelToFHIR(
        staysExcelFilePath, analysisExcelFilePath, xmlOutputFilePath
    )

    df = ETLCtrl.FHIR.getStaysDataFrameFromXML(xmlOutputFilePath)


    srcDF = DataFrame(XLSX.readtable(staysExcelFilePath,1))

    # Convert patient_ref to string to ensure the same type as the one returned by getStaysDataFrameFromXML
    srcDF.patient_ref = string.(srcDF.patient_ref)

    # Convert unit_in_time, unit_out_time, hospitalization_in_time, hospitalization_out_time
    # from DateTime to ZonedDateTime to ensure the same type as the one returned by getStaysDataFrameFromXML
    srcDF.unit_in_time = ZonedDateTime.(srcDF.unit_in_time, TRAQUERUtil.getTimeZone())
    srcDF.unit_out_time = passmissing(ZonedDateTime).(srcDF.unit_out_time, TRAQUERUtil.getTimeZone())
    srcDF.hospitalization_in_time = ZonedDateTime.(srcDF.hospitalization_in_time, TRAQUERUtil.getTimeZone())
    srcDF.hospitalization_out_time = passmissing(ZonedDateTime).(srcDF.hospitalization_out_time, TRAQUERUtil.getTimeZone())


    # Make lastname uppercase in srcDF to match the transformation done in convertExcelToFHIR
    srcDF.lastname = uppercase.(srcDF.lastname)


    # Order both dataframes by patient_ref and unit_in_time to ensure the same order of rows
    df = sort(df, [:patient_ref, :unit_in_time])
    srcDF = sort(srcDF, [:patient_ref, :unit_in_time])

    # Check number of rows match
    @test DataFrames.nrow(df) == DataFrames.nrow(srcDF)

    # List of columns to compare
    colsOfInterest = [
        :patient_ref,
        :firstname,
        :lastname,
        :birthdate,
        :hospitalization_in_time,
        :hospitalization_out_time,
        :unit_code_name,
        :unit_name,
        # :sector,
        :room,
        :unit_in_time,
        :unit_out_time
    ]

    # Check that both dataframes match for the columns of interest
    for (i, r) in enumerate(eachrow(srcDF))
        for col in colsOfInterest
            errorContext = "patient_ref=$(r.patient_ref), unit_in_time=$(r.unit_in_time), "*
                "column = $col: "*
                "excel value = $(srcDF[i,col]) of type $(typeof(srcDF[i,col])) vs "*
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

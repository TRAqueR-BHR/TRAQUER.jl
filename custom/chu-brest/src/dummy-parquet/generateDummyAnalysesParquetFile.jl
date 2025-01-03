function Custom.generateDummyAnalysesParquetFile()

    dirPath = joinpath(@__DIR__,"out","analyses")
    mkpath(dirPath)
    filePath = joinpath(dirPath,"analyses.parquet")
    filePathXLSX = joinpath(dirPath,"analyses.xlsx")

    # ###################### #
    # Initialize the columns #
    # ###################### #

    # Patient
    patientFirstname = String[]
    patientLastname = String[]
    patientBirthdate = Date[]
    patientRef = String[]

    # Analysis
    analysisRef = String[]
    requestTime = DateTime[]
    requestType = AnalysisRequestType.ANALYSIS_REQUEST_TYPE[]
    sampleMaterialType::Vector{Union{Missing, SampleMaterialType.SAMPLE_MATERIAL_TYPE}} =
        SampleMaterialType.SAMPLE_MATERIAL_TYPE[]
    resultTime::Vector{Union{Missing, DateTime}} = DateTime[]
    result::Vector{Union{Missing, AnalysisResultValueType.ANALYSIS_RESULT_VALUE_TYPE}} =
        AnalysisResultValueType.ANALYSIS_RESULT_VALUE_TYPE[]
    bacteriaName::Vector{Union{Missing, String}} = String[]

    # Comments per column
    comments = Dict(
        "requestTime" => "In the timezone of the hospital",
        "sampleMaterialType" => "The list of allowed values can be extended",
        "resultTime" => "In the timezone of the hospital",
    )

    # ################### #
    # Add some recordings #
    # ################### #

    # Request
    push!(patientFirstname, "André")
    push!(patientLastname, "Kerouec")
    push!(patientBirthdate, Date(1980,1,1))
    push!(patientRef, "P123456")
    push!(analysisRef, "A123456")
    push!(requestTime, DateTime(2024,10,1,23))
    push!(requestType, AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae)
    push!(sampleMaterialType, SampleMaterialType.tissue)
    push!(resultTime, missing)
    push!(result, missing)
    push!(bacteriaName, missing)

    # Result
    push!(patientFirstname, "André")
    push!(patientLastname, "Kerouec")
    push!(patientBirthdate, Date(1980,1,1))
    push!(patientRef, "P123456")
    push!(analysisRef, "A123456")
    push!(requestTime, DateTime(2024,10,1,23))
    push!(requestType, AnalysisRequestType.bacterial_culture_carbapenemase_producing_enterobacteriaceae)
    push!(sampleMaterialType, SampleMaterialType.tissue)
    push!(resultTime, DateTime(2024,10,2,15))
    push!(result, AnalysisResultValueType.positive)
    push!(bacteriaName, "Klebsiella pneumoniae")

    # ################################################### #
    # Create the DataFrame and generate the documentation #
    # ################################################### #
    df = DataFrame(

        # Patient
        patientFirstname = patientFirstname,
        patientLastname = patientLastname,
        patientBirthdate = patientBirthdate,
        patientRef = patientRef,

        # Analysis
        analysisRef = analysisRef,
        requestTime = requestTime,
        requestType = requestType,
        sampleMaterialType = sampleMaterialType,
        resultTime = resultTime,
        result = result,
        bacteriaName = bacteriaName

    )

    Custom.generateDummyDataFrameDescription(
        df,
        joinpath(dirPath,"README.md"),
        "Description of 'analyses' Parquet file",
        (
            "This file contains the description of the 'analyses' Parquet file.\n"
            * "Several lines can refer to the same analysis,\nEg. one line for the request"
            *" and one line for the result."
        ),
        comments
    )

    # ############################ #
    # Convert the enums to strings #
    # ############################ #
    df.requestType = (passmissing(string)).(df.requestType)
    df.result = (passmissing(string)).(df.result)
    df.sampleMaterialType = (passmissing(string)).(df.sampleMaterialType)

    # ##################################### #
    # Write the DataFrame to a Parquet file #
    # ##################################### #
    Parquet2.writefile(
        filePath,
        df
        ;
        # column_metadata = Dict(
        #     "requestType" => Dict(
        #         "allowed_values" => instances(AnalysisRequestType.ANALYSIS_REQUEST_TYPE) |>
        #             collect |>
        #             n -> string.(n) |>
        #             n -> join(n, ", ")
        #     )
        # ),
        # metadata=Dict(
        #     "requestType" => instances(AnalysisRequestType.ANALYSIS_REQUEST_TYPE) |>
        #         collect |>
        #         n -> string.(n) |>
        #         n -> join(n, ", ")
        # ),  # file wide metadata
    )

    TRAQUERUtil.serializeDataFrameToExcel(
        df,
        filePathXLSX
        ;translate = false,
        dropIdColumns = false
    )

    nothing

end

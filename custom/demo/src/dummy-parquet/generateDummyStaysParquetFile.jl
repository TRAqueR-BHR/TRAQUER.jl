function Custom.generateDummyStaysParquetFile()

    dirPath = joinpath(@__DIR__,"out","stays")
    mkpath(dirPath)
    filePath = joinpath(dirPath,"stays.parquet")
    filePathXLSX = joinpath(dirPath,"stays.xlsx")
    filePathCSV = joinpath(dirPath,"stays.csv")

    # ###################### #
    # Initialize the columns #
    # ###################### #

    # Patient
    patientFirstname = String[]
    patientLastname = String[]
    patientBirthdate = Date[]
    patientRef = String[]

    # Unit
    unitCodeName = String[]
    unitName = String[]

    # Stay
    inTime = ZonedDateTime[]
    outTime::Vector{Union{Missing, ZonedDateTime}} = ZonedDateTime[]
    hospitalizationInTime = ZonedDateTime[]
    hospitalizationOutTime::Vector{Union{Missing, ZonedDateTime}} = ZonedDateTime[]
    hospitalizationOutComment::Vector{Union{Missing, String}} = String[]
    room::Vector{Union{Missing, String}} = String[]
    sector::Vector{Union{Missing, String}} = String[]
    patientDiedDuringStay::Vector{Union{Missing, Bool}} = Bool[]

    # Comments per column
    comments = Dict(
        "inTime" => "In the timezone of the hospital",
        "outTime" => "In the timezone of the hospital",
        "hospitalizationInTime" => "In the timezone of the hospital",
        "hospitalizationOutTime" => "In the timezone of the hospital",
    )

    # ################### #
    # Add some recordings #
    # ################### #

    # In REA1
    push!(patientFirstname, "André")
    push!(patientLastname, "Kerouec")
    push!(patientBirthdate, Date(1980,1,1))
    push!(patientRef, "P123456")
    push!(unitCodeName, "REA1")
    push!(unitName, "Service de réanimation post-opératoire")
    push!(inTime, DateTime(2024,10,1,8)|>createHZDT)
    push!(outTime, missing)
    push!(hospitalizationInTime, DateTime(2024,10,1,8)|>createHZDT)
    push!(hospitalizationOutTime, missing)
    push!(hospitalizationOutComment, missing)
    push!(room, "137")
    push!(sector, missing)
    push!(patientDiedDuringStay, missing)

    # Out REA1
    push!(patientFirstname, "André")
    push!(patientLastname, "Kerouec")
    push!(patientBirthdate, Date(1980,1,1))
    push!(patientRef, "P123456")
    push!(unitCodeName, "REA1")
    push!(unitName, "Service de réanimation post-opératoire")
    push!(inTime, DateTime(2024,10,1,8)|>createHZDT)
    push!(outTime, DateTime(2024,10,3,8)|>createHZDT)
    push!(hospitalizationInTime, DateTime(2024,10,1,8)|>createHZDT)
    push!(hospitalizationOutTime, missing)
    push!(hospitalizationOutComment, missing)
    push!(room, "137")
    push!(sector, missing)
    push!(patientDiedDuringStay, missing)

    # ################################################### #
    # Create the DataFrame and generate the documentation #
    # ################################################### #

    df = DataFrame(

        # Patient
        patientFirstname = patientFirstname,
        patientLastname = patientLastname,
        patientBirthdate = patientBirthdate,
        patientRef = patientRef,

        # Unit
        unitCodeName = unitCodeName,
        unitName = unitName,

        # Stay
        inTime = inTime,
        outTime = outTime,
        hospitalizationInTime = hospitalizationInTime,
        hospitalizationOutTime = hospitalizationOutTime,
        hospitalizationOutComment = hospitalizationOutComment,
        room = room,
        sector = sector,
        patientDiedDuringStay = patientDiedDuringStay

    )

    Custom.generateDummyDataFrameDescription(
        df,
        joinpath(dirPath,"README.md"),
        "Description of 'stays' Parquet file",
        (
            "This file contains the description of the 'stays' Parquet file.\n"
            * "Several lines can refer to the same stay,\nEg. one line for when the patient"
            *" arrives in the unit and one line for when he leaves."
        ),
        comments
    )

    # ############################ #
    # Convert the enums to strings #
    # ############################ #

    # ##################################### #
    # Write the DataFrame to a Parquet file #
    # ##################################### #
    # Parquet2.writefile(
    #     filePath,
    #     df
    # )

    TRAQUERUtil.serializeDataFrameToExcel(
        df,
        filePathXLSX
        ;translate = false,
        dropIdColumns = false
    )

    # ################################### #
    # Write the DataFrame to a CSV file  #
    # ################################### #
    @info "Writing CSV file to $filePathCSV"
    CSV.write(filePathCSV, df)

    nothing

end

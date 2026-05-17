function TRAQUERUtil.readFirstNLinesOfCSVFile(
    filePath::String,
    nbOfLines::Integer
    ;csvFileKwargs...
)

    csvData = TRAQUERUtil.readFirstNLinesOfFile(
        filePath,
        nbOfLines+1 # Add one line to take into account the header line
    )

    # Create an IOBuffer from the string
    buffer = IOBuffer(csvData)

    # Parse the CSV data
    df = DataFrame(CSV.File(buffer;csvFileKwargs...))

    return df

end

function TRAQUERUtil.readFirstNLinesOfCSVFile(
    filePath::String,
    nbOfLines::Integer
    ;delim::String = ","
)

    csvData = TRAQUERUtil.readFirstNLinesOfFile(
        filePath,
        nbOfLines
        ;delim = delim
    )

    # Create an IOBuffer from the string
    buffer = IOBuffer(csvData)

    # Parse the CSV data
    df = DataFrame(CSV.File(buffer))

    return df

end

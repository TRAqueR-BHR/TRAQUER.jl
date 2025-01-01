function Custom.generateDummyDataFrameDescription(
    df::DataFrame,
    outPath::String
)

    # Get the column names
    colNames = names(df)

    # Get the column types
    colTypes = eltype.(eachcol(df))

    # Initialize markdown content
    markdownContent = "# DataFrame Description\n\n"

    for i in 1:length(colNames)

        colName = colNames[i]
        colType = colTypes[i]

        optional = colType isa Union ? true : false
        colType = Missings.nonmissingtype(colType)

        markdownContent *= "## Column: $colName\n"
        markdownContent *= "- Type: $colType\n"
        markdownContent *= "- Optional: $(optional ? "Yes" : "No")\n"

        if colType <: Base.Enum
            allowedValues = string.(collect(instances(colType)))
            markdownContent *= "- Allowed Values: $(join(allowedValues, ", "))\n"
        end

        markdownContent *= "\n"
    end

    # Write the markdown content to the file
    open(outPath, "w") do file
        write(file, markdownContent)
    end
end

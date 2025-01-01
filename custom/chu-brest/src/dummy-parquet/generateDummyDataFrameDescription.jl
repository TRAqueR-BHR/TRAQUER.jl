function Custom.generateDummyDataFrameDescription(
    df::DataFrame,
    outPath::String,
    title::String,
    intro::String,
    commentsPerColumn = Dict{Symbol, String}()
)

    # Get the column names
    colNames = names(df)

    # Get the column types
    colTypes = eltype.(eachcol(df))

    # Initialize markdown content
    markdownContent = "# $title\n\n"

    markdownContent *= "$intro\n\n"

    for i in 1:length(colNames)

        colName = colNames[i]
        colType = colTypes[i]

        isOptional = colType isa Union ? true : false
        colType = Missings.nonmissingtype(colType)
        isEnum = colType <: Base.Enum ? true : false

        markdownContent *= "## Column: $colName\n"
        if isEnum
            markdownContent *= "- Type: String (converted to enum $colType)\n"
        else
            markdownContent *= "- Type: $colType\n"
        end
        markdownContent *= "- Optional: $(isOptional ? "Yes" : "No")\n"

        if haskey(commentsPerColumn, colName)
            markdownContent *= "- Note: $(commentsPerColumn[colName])\n"
        end

        if colType <: Base.Enum
            allowedValues = string.(collect(instances(colType)))
            markdownContent *= "- Allowed Values:\n$(join("  - " .* allowedValues, "\n"))\n"
        end



        markdownContent *= "\n"
    end

    # Write the markdown content to the file
    open(outPath, "w") do file
        write(file, markdownContent)
    end
end

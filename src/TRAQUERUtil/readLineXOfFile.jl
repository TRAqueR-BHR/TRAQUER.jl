"""
    readLineXOfFile(filePath::String, lineNumber::Integer)

    # Usage
    # line = readLineXOfFile("pathToYourFile.txt", 5)  # read 5th line
"""
function TRAQUERUtil.readLineXOfFile(filePath::String, lineNumber::Integer)::String
    result = nothing
    open(filePath, "r") do file
        for (i, line) in enumerate(eachline(file))
            if i == lineNumber
                result = line
                break
            end
        end
    end
    isnothing(result) && error("File $filePath has fewer than $lineNumber lines")
    return result
end

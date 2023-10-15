function TRAQUERUtil.readFirstNLinesOfFile(filePath::String, n::Integer)
    result = ""
    # Convert to UTF-8 in case the file is ISO-8859-1
    StringEncodings.open(filePath, StringEncodings.enc"ISO-8859-1") do file
        for line in IterTools.take(eachline(file), n)
            result *= line * "\n"
        end
    end
    return result
end

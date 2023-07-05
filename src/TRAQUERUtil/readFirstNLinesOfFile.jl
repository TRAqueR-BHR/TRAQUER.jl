function TRAQUERUtil.readFirstNLinesOfFile(filePath::String, n::Integer)
    result = ""
    open(filePath, "r") do file
        for line in IterTools.take(eachline(file), n)
            result *= line * "\n"
        end
    end
    return result
end

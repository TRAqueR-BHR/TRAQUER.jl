"""
Usage:
copyLinesToDestFile("path_to_source_file.txt", [1,3,5], "path_to_destination_file.txt")
"""
function copyLinesToDestFile(sourceFile::String, lineNums::Vector{Integer}, destFile::String)

    # Check if the destination directory exists and create it if it doesn't
    destDir = dirname(destFile)
    if !isdir(destDir)
        mkpath(destDir)
    end

    # Open the destination file for writing
    open(destFile, "w") do df
        # Open the source file for reading
        open(sourceFile, "r") do sf
            # Iterate over the lines in the source file
            for (i, line) in enumerate(eachline(sf))
                # If the current line number is in the list, write it to the destination file
                if i in lineNums
                    write(df, line * "\n")
                end
            end
        end
    end
end

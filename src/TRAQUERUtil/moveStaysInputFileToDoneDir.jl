function TRAQUERUtil.moveStaysInputFileToDoneDir(filePath::String)

    doneDirPath = TRAQUERUtil.getDoneInputFilesDir()

    # Use regex to extract date from filePath
    m = match(r"(\d{4}-\d{2}-\d{2})", filePath)

    # If match found, extract date, create folder, and move file
    if m !== nothing
        dateStr = m[1]
        folderPath = joinpath(doneDirPath, "stays", dateStr)

        # Check if directory exists, if not create it
        if !isdir(folderPath)
            mkpath(folderPath)
        end

        # Move the file to the new folder
        destination = joinpath(folderPath, basename(filePath))
        mv(filePath, destination ;force=true)

        @info "Moved $filePath to $destination"

    else
        error("$filePath doesn't match expected pattern.")
    end
end

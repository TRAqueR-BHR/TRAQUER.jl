function TRAQUERUtil.moveInputFileToProcessingDir(filePath::String)::String

    # Create a temporary subfolder in the very unlikely case where another file with the
    # the same name were copied to the processing dir before it is moved somewhere else
    processingDirPath = joinpath(
        TRAQUERUtil.getProcessingInputFilesDir(),
        "$(string(now(getTimeZone())))"
    )
    mkdir(processingDirPath)
    destPath = joinpath(processingDirPath, basename(filePath))
    mv(filePath, destPath ;force=true)
    @info "Moved $filePath to $destPath"

    return destPath

end

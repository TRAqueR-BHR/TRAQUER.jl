function ETLCtrl.serializeRowsInError(
    dfOfRowsInError::DataFrame,
    csvFilepath::String,
    problemsDir::String
)

    srcFileBasename = basename(csvFilepath)
    mkpath(problemsDir)
    filepathForLinesWithProblems = joinpath(problemsDir,"$(srcFileBasename)-lines-in-error.csv")
    filepathForErrorLog = joinpath(problemsDir,"$(srcFileBasename)-error.log")
    @info problemsDir

    # Initialize the file of the content in error with the header of the source CSV file
    contentInError = TRAQUERUtil.readLineXOfFile(csvFilepath, 1)

    # Initialize the error log
    errorLog = "This is the error log for file[$srcFileBasename]"

    for rowTmp in eachrow(dfOfRowsInError)
        lineNumInSrcFile = rowTmp.lineNumInSrcFile
        error = rowTmp.error

        lineContent = TRAQUERUtil.readLineXOfFile(csvFilepath, lineNumInSrcFile)

        contentInError *= "\n" * lineContent
        errorLog *= "\n\n" * lineContent
        errorLog *= "\n" * "Line number in src file[$lineNumInSrcFile]"
        errorLog *= "\n" * error

    end

    # Write to the files
    open(filepathForLinesWithProblems, "w") do file
        write(file, contentInError)
    end
    open(filepathForErrorLog, "w") do file
        write(file, errorLog)
    end

end

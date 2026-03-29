function ETLCtrl.FHIR.validateAgainstSchema(xmlFilePath::String, xsdFilePath::String)

    cmd = `xmllint --noout --schema $xsdFilePath $xmlFilePath`
    stderrBuffer = IOBuffer()

    process = try
        run(pipeline(ignorestatus(cmd); stdout = devnull, stderr = stderrBuffer))
    catch e
        if isa(e, Base.IOError)
            throw(ErrorException("xmllint command not found. Please install libxml2-utils/xmllint."))
        end
        rethrow(e)
    end

    validationOutput = String(take!(stderrBuffer))

    errorLines::Vector{String} = filter(
        !isempty,
        split(validationOutput, '\n')
    )

    # Always drop the last line that tells whether the file is valid or not
    if !isempty(errorLines)
        pop!(errorLines)
    end

    if success(process)
        return (true, errorLines)
    else
        return (false, errorLines)
    end
end

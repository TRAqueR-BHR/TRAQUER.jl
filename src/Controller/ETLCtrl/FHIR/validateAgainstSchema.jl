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

    rawLines = filter(
        !isempty,
        split(validationOutput, '\n')
    )

    # Always drop the last line that tells whether the file is valid or not
    if !isempty(rawLines)
        pop!(rawLines)
    end

    # xmllint lines follow the format: "{fileName}:{lineNumber}: {errorMessage}"
    linePattern = r"^(.+):([0-9]+): (.+)$"

    errors::Vector{Model.FhirXmlError} = map(rawLines) do line
        m = match(linePattern, line)
        if m !== nothing
            Model.FhirXmlError(
                fileName     = String(m[1]),
                lineNumber   = Int32(parse(Int, m[2])),
                errorMessage = String(m[3]),
            )
        else
            Model.FhirXmlError(errorMessage = line)
        end
    end

    if success(process)
        return (true, errors)
    else
        return (false, errors)
    end
end

function ETLCtrl.FHIR.formatXMLFile(inputFilePath::String, outputFilePath::String)
    cmd = `xmllint --format $inputFilePath -o $outputFilePath`
    run(cmd)
end

function ETLCtrl.FHIR.formatXMLFile(inputFilePath::String)
    tmpFilePath = inputFilePath * ".tmp"
    try
        ETLCtrl.FHIR.formatXMLFile(inputFilePath, tmpFilePath)
        mv(tmpFilePath, inputFilePath, force = true)
    catch e
        isfile(tmpFilePath) && rm(tmpFilePath)
        rethrow(e)
    end
end

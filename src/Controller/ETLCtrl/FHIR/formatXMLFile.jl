function ETLCtrl.FHIR.formatXMLFile(inputFilePath::String, outputFilePath::String)
    cmd = `xmllint --format $inputFilePath -o $outputFilePath`
    run(cmd)
end

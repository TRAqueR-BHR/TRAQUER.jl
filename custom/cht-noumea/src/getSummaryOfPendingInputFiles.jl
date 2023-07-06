function Custom.getSummaryOfPendingInputFiles(folderPath::String)
     # Get a list of all .csv files in the directory
     csv_files = filter(file -> occursin(".csv", file), readdir(folderPath))

     # Sort the files by modification time
     sorted_files = sort(csv_files, by=file -> mtime(joinpath(folderPath, file)), rev=true)

     # Loop over the sorted files
     for file in sorted_files
         # Determine the full path of the file
         csvFilePath = joinpath(folderPath, file)

         # Call the appropriate function based on the file name
         if occursin("dxcare", file)
             Custom.getBasicInformationAboutStaysInputFile(csvFilePath)
         elseif occursin("inlog", file)
             Custom.getBasicInformationAboutAnalysesInputFile(csvFilePath)
         end
         println("")
     end
end

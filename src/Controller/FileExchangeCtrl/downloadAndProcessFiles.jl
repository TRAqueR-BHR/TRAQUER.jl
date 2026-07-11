function FileExchangeCtrl.downloadAndProcessFiles(
    fileURLs::Vector{String},
    cryptPwd::String,
    dbconn::LibPQ.Connection
)

    # Download files at given URL (it can be s3:// or file://)
    # NOTE: If s3 uri then use S3Ctrl.download
    # TODO

    # For each file xml file, download the sidecar file (name of sidecar file is same as xml
    # file but with .sidecar extension).
    # Create a vector of tuples (xmlFilePath, sideCarFilePath) for each file
    # TODO


    # Loop through the vector of tuples and process each xml file with its sidecar file to
    # create a vector of decrypted files. The processing steps are:
    # For each tuple (xmlFilePath, sideCarFilePath)
    #  1. Extract the kdfChildKeyRef from the sidecar file using
    #     FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile
    #  2. Retrieve the KdfChildKey entity from the database using the kdfChildKeyRef
    #     Use PostgresORM.retrieve_one_entity to retrieve the KdfChildKey entity from
    #     the database using KdfChildKey(ref = childKeyRef)
    #  3. Derive the child key hex using KdfChildKeyCtrl.deriveEncodedChildKey
    #  4. Decrypt the file using FileExchangeCtrl.decryptFile with the derived child key hex
    #     and add the decrypted file path to a vector of decrypted files

    # Loop through the vector of decrypted files and process each decrypted file
    # For each decrypted file:
    #  1. Create a dataframe of analyses using ETLCtrl.FHIR.parseXMLToAnalysesDF
    #  2. Create a dataframe of stays using ETLCtrl.FHIR.parseXMLToStaysDF
    #  3. Import the analyses dataframe using ETLCtrl.importAnalysesDF
    #  4. Import the stays dataframe using ETLCtrl.importStaysDF

    # Move the processed files to the processed directory


end

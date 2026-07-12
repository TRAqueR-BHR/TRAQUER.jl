function FileExchangeCtrl.downloadAndProcessFile(
    fileURL::String,
    cryptPwd::String,
    dbconn::LibPQ.Connection
)

    # Download file at given URL (it can be s3:// or file://)
    # NOTE: If s3 uri then use S3Ctrl.download
    # TODO

    # Download the sidecar file (name of sidecar file is same as xml file but with .sidecar
    # extension).
    # TODO

    # Process the xml file with its sidecar file to create a decrypted file. The processing
    # steps are:
    #  1. Extract the kdfChildKeyRef from the sidecar file using
    #     FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile
    #  2. Retrieve the KdfChildKey entity from the database using the kdfChildKeyRef
    #     Use PostgresORM.retrieve_one_entity to retrieve the KdfChildKey entity from
    #     the database using KdfChildKey(ref = childKeyRef)
    #  3. Derive the child key hex using KdfChildKeyCtrl.deriveEncodedChildKey
    #  4. Decrypt the file using FileExchangeCtrl.decryptFile with the derived child key hex
    #     and add the decrypted file path to a vector of decrypted files
    # TODO

    # Process the decrypted file:
    #  1. Create a dataframe of analyses using ETLCtrl.FHIR.parseXMLToAnalysesDF
    #  2. Create a dataframe of stays using ETLCtrl.FHIR.parseXMLToStaysDF
    #  3. Import the analyses dataframe using ETLCtrl.importAnalysesDF
    #  4. Import the stays dataframe using ETLCtrl.importStaysDF
    # TODO

    # Move the processed files to the processed directory
    # TODO

end

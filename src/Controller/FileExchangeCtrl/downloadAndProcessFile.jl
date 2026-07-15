function FileExchangeCtrl.downloadAndProcessFile(
    fileURL::String,
    cryptPwd::String,
    dbconn::LibPQ.Connection
)

    # Download file at given URL (it can be s3:// or file://)
    # NOTE: If s3 uri then use S3Ctrl.download ; if file uri move the file to
    #       Conf.getFSProcessingInputFilesDir()
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
    # TODO

    # Process the decrypted file in a try-catch block
    #  1. Create a dataframe of analyses using ETLCtrl.FHIR.parseXMLToAnalysesDF
    #  2. Create a dataframe of stays using ETLCtrl.FHIR.parseXMLToStaysDF
    #  3. Import the analyses dataframe using ETLCtrl.importAnalysesDF
    #  4. Import the stays dataframe using ETLCtrl.importStaysDF
    #  5. Move the processed files to the 'done' directory:
    #     Conf.getFSDoneInputFilesDir()
    #  NOTE: - In the 'catch' block  move the crypted file and the sidecar to either
    #    Conf.getS3InputFilesProblemsDir() or Conf.getFSInputFilesProblemsDir() depending
    #    on the fileURL scheme. Also notify the admins using
    #    ExceptionCtrl.logExceptionAndNotifyAdmin
    #        - In the 'finally' block, delete the decrypted file and the sidecar file (may be missing)
    # TODO


end

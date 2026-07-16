"""
    downloadAndProcessFile(
        fileURL::String,
        cryptPwd::String,
        dbconn::LibPQ.Connection,
        ;alsoProcessNewlyIntegratedData::Bool,
    )

End-to-end processing of a single file exchanged via the file-exchange
workflow.

The pipeline runs as follows:
1. Move the crypted XML file pointed to by `fileURL` (which may be an
   `s3://` or `file://` URL) and its sidecar file into the processing
   area. For `s3://` URLs the files are copied on S3 from the pending
   directory to the processing directory; for `file://` URLs the files
   are moved locally into the local processing sub-directory.
2. For `s3://` URLs only, download the files from the S3 processing
   directory into the local processing sub-directory. For `file://`
   URLs the files are already local after step 1.
3. Read the child key reference from the sidecar file, look up the
   matching `KdfChildKey` row in the database and re-derive the child
   key hex from the instance master key, salt and info.
4. Decrypt the file with the derived child key hex as the gpg
   passphrase.
5. Parse the decrypted XML into analyses and stays DataFrames and
   import them through the ETL controllers. If `alsoProcessNewlyIntegratedData`
   is `true`, also trigger downstream processing of the newly integrated
   data.
6. Move the crypted file and its sidecar to the "done" directory
   (`Conf.getS3DoneInputFilesDir()` or `Conf.getFSDoneInputFilesDir()`
   depending on the URL scheme).

If anything fails, the catch block moves the crypted file and sidecar
to the "problems" directory
(`Conf.getS3InputFilesProblemsDir()` or
`Conf.getFSInputFilesProblemsDir()` depending on the URL scheme) and
notifies the admins via `ExceptionCtrl.logExceptionAndNotifyAdmin`. The
finally block removes the decrypted file and the local sidecar copy.

`cryptPwd` is the user-supplied passphrase used to decrypt patient
records stored encrypted in the database; it is forwarded unchanged to
the ETL import functions.

`alsoProcessNewlyIntegratedData` is forwarded unchanged to
`processDecryptedXmlFile` and controls whether the expensive
post-import processing step
(`ETLCtrl.processNewlyIntegratedData`) is triggered after the import.
"""
function FileExchangeCtrl.downloadAndProcessFile(
    fileURL::String,
    cryptPwd::String,
    dbconn::LibPQ.Connection,
    ;alsoProcessNewlyIntegratedData::Bool,
)

    parsedFileURL = FileExchangeCtrl.parseFileURL(fileURL)

    # Create a per-invocation sub-directory inside the processing dir so concurrent
    # calls don't clash on file basenames.
    processingSubDirPath = mkpath(joinpath(
        TRAQUERUtil.Conf.getFSProcessingInputFilesDir(),
        string(now(TRAQUERUtil.getTimeZone())),
    ))

    cryptedFilePath = ""
    sidecarFilePath = ""
    decryptedFilePath = ""

    try

        # Move the crypted XML file and its sidecar file into the processing area
        # (s3 → pending → processing on S3, file:// → local move).
        FileExchangeCtrl.moveCryptedAndSidecarFilesToProcessingDir(
            fileURL,
            processingSubDirPath,
        )

        # For s3:// URLs only, pull the files from the S3 processing directory down
        # to the local processing directory. For file:// URLs the files are already
        # local from the move step.
        if parsedFileURL.scheme === :s3
            (cryptedFilePath, sidecarFilePath) =
                FileExchangeCtrl.downloadCryptedAndSidecarFilesToProcessingDir(
                    parsedFileURL,
                    processingSubDirPath,
                )
        else
            cryptedBasename = basename(fileURL)
            cryptedFilePath = joinpath(processingSubDirPath, cryptedBasename)
            sidecarFilePath = joinpath(
                processingSubDirPath, "$(cryptedBasename).sidecar",
            )
        end

        # Decrypt the file
        decryptedFilePath = FileExchangeCtrl.decryptFileWithSidecar(
            cryptedFilePath,
            sidecarFilePath,
            dbconn,
        )

        # Parse the decrypted XML, import analyses and stays, and trigger downstream
        # processing of the newly integrated data.
        FileExchangeCtrl.processDecryptedXmlFile(
            decryptedFilePath,
            cryptPwd,
            dbconn,
            ;alsoProcessNewlyIntegratedData = alsoProcessNewlyIntegratedData,
        )

        # On success, move the crypted file and its sidecar to the "done" directory
        FileExchangeCtrl.moveCryptedAndSidecarFilesToDoneDir(
            cryptedFilePath, sidecarFilePath, parsedFileURL,
        )

    catch e
        # On any failure, move the crypted file and its sidecar (when present)
        # to the "problems" directory and notify the admins.
        ExceptionCtrl.logExceptionAndNotifyAdmin(
            e, stacktrace(catch_backtrace()),
        )
        if !isempty(cryptedFilePath) && isfile(cryptedFilePath)
            try
                FileExchangeCtrl.moveCryptedAndSidecarFilesToProblemsDir(
                    cryptedFilePath, sidecarFilePath, parsedFileURL,
                )
            catch moveEx
                ExceptionCtrl.logExceptionAndNotifyAdmin(
                    moveEx, stacktrace(catch_backtrace()),
                )
            end
        end
    finally
        # Always clean up the decrypted file and the local sidecar copy (either
        # or both may be missing).
        if !isempty(decryptedFilePath) && isfile(decryptedFilePath)
            rm(decryptedFilePath; force = true)
        end
        if !isempty(sidecarFilePath) && isfile(sidecarFilePath)
            rm(sidecarFilePath; force = true)
        end
    end

    return nothing

end

"""
   downloadAndProcessFile(
       fileURL::String,
       dbconn::LibPQ.Connection,
       ;alsoProcessNewlyIntegratedData::Bool,
   )

Convenience overload for system-initiated calls (e.g. scheduled tasks)
that have no user context. Uses the instance master key as the
encryption passphrase for the patient decryption done by the ETL
imports. The `alsoProcessNewlyIntegratedData` keyword is forwarded
unchanged to the 3-argument method.
"""
function FileExchangeCtrl.downloadAndProcessFile(
    fileURL::String,
    dbconn::LibPQ.Connection,
    ;alsoProcessNewlyIntegratedData::Bool,
)

    cryptPwd = CacheCtrl.getInstanceMasterKey()

    FileExchangeCtrl.downloadAndProcessFile(
        fileURL,
        cryptPwd,
        dbconn,
        ;alsoProcessNewlyIntegratedData = alsoProcessNewlyIntegratedData,
    )

end

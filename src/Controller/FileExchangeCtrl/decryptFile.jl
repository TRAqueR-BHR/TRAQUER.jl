function FileExchangeCtrl.decryptFile(filePath::String; cryptPwd::String)::String

    # Decrypt the file using gpg and the provided kdfChildKey to a temporary file
    tempDecryptedFilePath = tempname()
    gpgCommand = `gpg --batch --yes --passphrase $cryptPwd --output $tempDecryptedFilePath --decrypt $filePath`
    run(gpgCommand)

    return tempDecryptedFilePath

end

function FileExchangeCtrl.decryptFile(filePath::String; sideCarFilePath::String)::String

    childKeyRef = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(sideCarFilePath)

    FileExchangeCtrl.decryptFile(filePath; cryptPwd = childKeyRef)

end

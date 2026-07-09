function FileExchangeCtrl.encryptFile(filePath::String, cryptPwd::String)::String

    # Encrypt the file using gpg and the provided kdfChildKey to a temporary file
    tempEncryptedFilePath = tempname()
    gpgCommand = `gpg --batch --yes --passphrase $cryptPwd --output $tempEncryptedFilePath --symmetric $filePath`
    run(gpgCommand)

    return tempEncryptedFilePath

end

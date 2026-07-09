"""
    FileExchangeCtrl.encryptFile(filePath::String, cryptPwd::String)::String

Encrypt a file using gpg and the provided cryptPwd to a temporary file. Return the path to
the encrypted file.
"""
function FileExchangeCtrl.encryptFile(filePath::String, cryptPwd::String)::String

    tempEncryptedFilePath = tempname()
    gpgCommand = `gpg --batch --yes --passphrase $cryptPwd --output $tempEncryptedFilePath --symmetric $filePath`
    run(gpgCommand)

    return tempEncryptedFilePath

end

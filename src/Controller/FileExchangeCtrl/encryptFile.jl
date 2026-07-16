"""
    FileExchangeCtrl.encryptFile(
        filePath::String,
        cryptPwd::String,
        useSourceFileName::Bool,
    )::String

Encrypt a file using gpg and the provided `cryptPwd`. The returned
path always ends with `.gpg` so the file is recognised as a
gpg-encrypted file by external tooling and round-trips cleanly with
`FileExchangeCtrl.decryptFile`.

When `useSourceFileName` is `true`, the encrypted file is created next
to the source file, in the same directory and with the same basename
plus the `.gpg` extension (e.g. `/tmp/foo.xml` →
`/tmp/foo.xml.gpg`). When `useSourceFileName` is `false`, the encrypted
file is created in the system temp directory with a `tempname()`-generated
basename plus the `.gpg` extension.
"""
function FileExchangeCtrl.encryptFile(
    filePath::String,
    cryptPwd::String,
    useSourceFileName::Bool,
)::String

    tempEncryptedFilePath = if useSourceFileName
        joinpath(dirname(filePath), basename(filePath) * ".gpg")
    else
        tempname() * ".gpg"
    end
    gpgCommand = `gpg --batch --yes --passphrase $cryptPwd --output $tempEncryptedFilePath --symmetric $filePath`
    run(gpgCommand)

    return tempEncryptedFilePath

end

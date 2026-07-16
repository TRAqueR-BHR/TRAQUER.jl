include("__prerequisite.jl")

# Helpers
# -------

# Encrypt `plaintextPath` with `cryptPwd` via gpg. Used by error-path tests
# that need an encrypted file with a specific passphrase that does not match
# any derived child key.
function _gpgEncrypt(plaintextPath::String, cryptPwd::String)::String
    out = tempname() * ".gpg"
    run(pipeline(
        `gpg --batch --yes --passphrase $cryptPwd --output $out --symmetric $plaintextPath`,
        stderr = devnull,
    ))
    return out
end

function _writeSidecar(dir::String, contents::String)::String
    path = joinpath(dir, "sidecar.txt")
    write(path, contents)
    return path
end

# Provision a fresh KdfChildKey row and return `(ref, childKeyHex)`. The caller
# is responsible for cleanup via `_deleteKdfChildKeyByRef(dbconn, ref)`.
function _provisionKdfChildKey(dbconn)
    generated = FileExchangeCtrl.getKdfChildKey(dbconn)
    return (generated.ref, generated.childKeyHex)
end

function _deleteKdfChildKeyByRef(dbconn, ref)
    "DELETE FROM crypt.kdf_child_key WHERE ref = \$1" |>
    query -> PostgresORM.execute_plain_query(query, [ref], dbconn)
    return nothing
end

# Tests
# ------
# Each test provisions and tears down its own KdfChildKey row.

@testset "Test FileExchangeCtrl.decryptFileWithSidecar" begin

    @testset "decryptFileWithSidecar(filePath, sidecarFilePath, dbconn) round-trips a small text file" begin
        result = TRAQUERUtil.createDBConnAndExecute() do dbconn
            ref, childKeyHex = _provisionKdfChildKey(dbconn)
            try
                mktempdir() do dir
                    plaintext  = "sidecar-plaintext-$(uuid4())"
                    inputPath  = joinpath(dir, "plain.txt")
                    write(inputPath, plaintext)

                    encryptedPath = FileExchangeCtrl.encryptFile(inputPath, childKeyHex, true)
                    sidecarPath   = joinpath(
                        dirname(encryptedPath),
                        basename(inputPath) * ".gpg.sidecar",
                    )
                    FileExchangeCtrl.createSidecarFile(sidecarPath, ref)

                    decryptedPath = FileExchangeCtrl.decryptFileWithSidecar(
                        encryptedPath, sidecarPath, dbconn,
                    )

                    try
                        @test isfile(decryptedPath)
                        @test read(decryptedPath, String) == plaintext
                    finally
                        rm(encryptedPath; force = true)
                        rm(decryptedPath; force = true)
                        rm(sidecarPath;   force = true)
                    end
                end
            finally
                _deleteKdfChildKeyByRef(dbconn, ref)
            end
            return nothing
        end
        @test isnothing(result)
    end

    @testset "decryptFileWithSidecar(filePath, sidecarFilePath, dbconn) works when sidecar is embedded in larger text" begin
        result = TRAQUERUtil.createDBConnAndExecute() do dbconn
            ref, childKeyHex = _provisionKdfChildKey(dbconn)
            try
                mktempdir() do dir
                    plaintext  = "embedded-$(uuid4())"
                    inputPath  = joinpath(dir, "plain.txt")
                    write(inputPath, plaintext)

                    encryptedPath = FileExchangeCtrl.encryptFile(inputPath, childKeyHex, true)
                    sidecarContents = string(
                        "# sidecar metadata\n",
                        "checksum: deadbeef\n",
                        "key_ref=$ref\n",
                        "uploadedAt: 2026-01-01T00:00:00Z\n",
                    )
                    sidecarPath = _writeSidecar(dir, sidecarContents)

                    decryptedPath = FileExchangeCtrl.decryptFileWithSidecar(
                        encryptedPath, sidecarPath, dbconn,
                    )

                    try
                        @test read(decryptedPath, String) == plaintext
                    finally
                        rm(encryptedPath; force = true)
                        rm(decryptedPath; force = true)
                        rm(sidecarPath;   force = true)
                    end
                end
            finally
                _deleteKdfChildKeyByRef(dbconn, ref)
            end
            return nothing
        end
        @test isnothing(result)
    end

    @testset "decryptFileWithSidecar(filePath, sidecarFilePath, dbconn) errors on missing sidecar file" begin
        result = TRAQUERUtil.createDBConnAndExecute() do dbconn
            ref, childKeyHex = _provisionKdfChildKey(dbconn)
            try
                mktempdir() do dir
                    inputPath = joinpath(dir, "plain.txt")
                    write(inputPath, "anything")

                    encryptedPath   = FileExchangeCtrl.encryptFile(inputPath, childKeyHex, true)
                    missingSidecar  = joinpath(dir, "no-such-sidecar.txt")

                    try
                        @test_throws SystemError FileExchangeCtrl.decryptFileWithSidecar(
                            encryptedPath, missingSidecar, dbconn,
                        )
                    finally
                        rm(encryptedPath; force = true)
                    end
                end
            finally
                _deleteKdfChildKeyByRef(dbconn, ref)
            end
            return nothing
        end
        @test isnothing(result)
    end

    @testset "decryptFileWithSidecar(filePath, sidecarFilePath, dbconn) errors when sidecar has no matching key" begin
        result = TRAQUERUtil.createDBConnAndExecute() do dbconn
            ref, childKeyHex = _provisionKdfChildKey(dbconn)
            try
                mktempdir() do dir
                    inputPath = joinpath(dir, "plain.txt")
                    write(inputPath, "anything")

                    encryptedPath = FileExchangeCtrl.encryptFile(inputPath, childKeyHex, true)
                    sidecarPath   = _writeSidecar(dir, "no relevant line in here\n")

                    try
                        @test_throws ErrorException FileExchangeCtrl.decryptFileWithSidecar(
                            encryptedPath, sidecarPath, dbconn,
                        )
                    finally
                        rm(encryptedPath; force = true)
                        rm(sidecarPath;   force = true)
                    end
                end
            finally
                _deleteKdfChildKeyByRef(dbconn, ref)
            end
            return nothing
        end
        @test isnothing(result)
    end

    @testset "decryptFileWithSidecar(filePath, sidecarFilePath, dbconn) errors when no KdfChildKey exists for the sidecar ref" begin
        # Sidecar parses fine but refers to a ref that has no row in the DB.
        # We allocate a fresh ref, immediately remove the row, and expect the
        # function to error before reaching gpg.
        result = TRAQUERUtil.createDBConnAndExecute() do dbconn
            ref, _ = _provisionKdfChildKey(dbconn)
            _deleteKdfChildKeyByRef(dbconn, ref)

            mktempdir() do dir
                inputPath = joinpath(dir, "plain.txt")
                write(inputPath, "anything")

                encryptedPath = _gpgEncrypt(inputPath, "any-pwd")
                sidecarPath   = _writeSidecar(dir, "key_ref=$ref\n")

                try
                    @test_throws ErrorException FileExchangeCtrl.decryptFileWithSidecar(
                        encryptedPath, sidecarPath, dbconn,
                    )
                finally
                    rm(encryptedPath; force = true)
                    rm(sidecarPath;   force = true)
                end
            end
            return nothing
        end
        @test isnothing(result)
    end

    @testset "decryptFileWithSidecar(filePath, sidecarFilePath, dbconn) errors when the underlying gpg decrypt fails" begin
        # Sidecar points to a real KdfChildKey, but the file was encrypted
        # with a different passphrase. The child-key derivation succeeds but
        # gpg cannot open the file.
        result = TRAQUERUtil.createDBConnAndExecute() do dbconn
            ref, _ = _provisionKdfChildKey(dbconn)
            try
                mktempdir() do dir
                    inputPath = joinpath(dir, "plain.txt")
                    write(inputPath, "secret-$(uuid4())")

                    encryptedPath = _gpgEncrypt(inputPath, "actual-pwd")
                    sidecarPath   = _writeSidecar(dir, "key_ref=$ref\n")

                    try
                        @test_throws ProcessFailedException FileExchangeCtrl.decryptFileWithSidecar(
                            encryptedPath, sidecarPath, dbconn,
                        )
                    finally
                        rm(encryptedPath; force = true)
                        rm(sidecarPath;   force = true)
                    end
                end
            finally
                _deleteKdfChildKeyByRef(dbconn, ref)
            end
            return nothing
        end
        @test isnothing(result)
    end
end

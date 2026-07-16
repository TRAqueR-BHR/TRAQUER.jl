include("__prerequisite.jl")

# Helpers for setting up encrypted fixtures without depending on
# FileExchangeCtrl.encryptFile (keeps the kwarg-method tests independent of
# its correctness).

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

# Helper for sidecar-driven tests: provision a fresh KdfChildKey row, return
# `(ref, childKeyHex)` so the test can encrypt with the real derived key. The
# caller is responsible for cleanup via `_deleteKdfChildKeyByRef(dbconn, ref)`.
function _provisionKdfChildKey(dbconn)
    generated = FileExchangeCtrl.getKdfChildKey(dbconn)
    return (generated.ref, generated.childKeyHex)
end

function _deleteKdfChildKeyByRef(dbconn, ref)
    "DELETE FROM crypt.kdf_child_key WHERE ref = \$1" |>
    query -> PostgresORM.execute_plain_query(query, [ref], dbconn)
    return nothing
end

@testset "Test FileExchangeCtrl.decryptFile" begin

    # ------------------------------------------------------------ decryptFile(filePath; cryptPwd)

    @testset "decryptFile(filePath; cryptPwd) round-trips a small text file" begin
        mktempdir() do dir
            plaintext = "hello world $(uuid4())\n"
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, plaintext)

            encryptedPath = _gpgEncrypt(inputPath, "roundtrip-pwd")
            decryptedPath = FileExchangeCtrl.decryptFile(encryptedPath; cryptPwd = "roundtrip-pwd")

            try
                @test decryptedPath != encryptedPath
                @test isfile(decryptedPath)
                @test read(decryptedPath, String) == plaintext
            finally
                rm(encryptedPath;   force = true)
                rm(decryptedPath;   force = true)
            end
        end
    end

    @testset "decryptFile(filePath; cryptPwd) round-trips binary content" begin
        mktempdir() do dir
            binary   = rand(UInt8, 4096)
            inputPath = joinpath(dir, "blob.bin")
            write(inputPath, binary)

            encryptedPath = _gpgEncrypt(inputPath, "bin-pwd")
            decryptedPath = FileExchangeCtrl.decryptFile(encryptedPath; cryptPwd = "bin-pwd")

            try
                @test read(decryptedPath) == binary
            finally
                rm(encryptedPath; force = true)
                rm(decryptedPath; force = true)
            end
        end
    end

    @testset "decryptFile(filePath; cryptPwd) round-trips a larger file" begin
        mktempdir() do dir
            big      = rand(UInt8, 1024 * 1024)  # 1 MiB
            inputPath = joinpath(dir, "big.bin")
            write(inputPath, big)

            encryptedPath = _gpgEncrypt(inputPath, "big-pwd")
            decryptedPath = FileExchangeCtrl.decryptFile(encryptedPath; cryptPwd = "big-pwd")

            try
                @test filesize(decryptedPath) == length(big)
                @test read(decryptedPath) == big
            finally
                rm(encryptedPath; force = true)
                rm(decryptedPath; force = true)
            end
        end
    end

    @testset "decryptFile(filePath; cryptPwd) round-trips an empty file" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "empty.txt")
            write(inputPath, "")

            encryptedPath = _gpgEncrypt(inputPath, "empty-pwd")
            decryptedPath = FileExchangeCtrl.decryptFile(encryptedPath; cryptPwd = "empty-pwd")

            try
                @test isfile(decryptedPath)
                @test read(decryptedPath, String) == ""
            finally
                rm(encryptedPath; force = true)
                rm(decryptedPath; force = true)
            end
        end
    end

    @testset "decryptFile(filePath; cryptPwd) errors on wrong passphrase" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "secret-$(uuid4())")

            encryptedPath = _gpgEncrypt(inputPath, "correct-pwd")
            try
                @test_throws ProcessFailedException FileExchangeCtrl.decryptFile(
                    encryptedPath; cryptPwd = "wrong-pwd",
                )
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "decryptFile(filePath; cryptPwd) errors on missing input file" begin
        mktempdir() do dir
            missingPath = joinpath(dir, "does-not-exist.gpg")
            @test_throws ProcessFailedException FileExchangeCtrl.decryptFile(
                missingPath; cryptPwd = "any-pwd",
            )
        end
    end

    @testset "decryptFile(filePath; cryptPwd) returns a path under the system temp dir" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "locate me")

            encryptedPath = _gpgEncrypt(inputPath, "locate-pwd")
            decryptedPath = FileExchangeCtrl.decryptFile(encryptedPath; cryptPwd = "locate-pwd")

            try
                @test isfile(decryptedPath)
                @test startswith(realpath(dirname(decryptedPath)), realpath(tempdir()))
            finally
                rm(encryptedPath; force = true)
                rm(decryptedPath; force = true)
            end
        end
    end

    # ------------------------------------------------------------ decryptFileWithSidecar(...)
    # These tests exercise the sidecar-driven entry point, which derives the
    # passphrase from a `crypt.kdf_child_key` row referenced by the sidecar
    # file. Each test provisions and tears down its own KdfChildKey row.

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
        # We allocate a fresh ref, never insert a matching row, and expect
        # the function to error before reaching gpg.
        result = TRAQUERUtil.createDBConnAndExecute() do dbconn
            ref, _ = _provisionKdfChildKey(dbconn)
            # Delete the row right away so the ref stays "orphaned" for the test.
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
            # Sidecar will point to a fresh ref, but the file is encrypted with
            # an unrelated passphrase so the derived child key cannot open it.
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

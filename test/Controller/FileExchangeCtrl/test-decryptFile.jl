include("__prerequisite.jl")

# Helpers for setting up encrypted fixtures without depending on
# FileExchangeCtrl.encryptFile (keeps this test independent of its correctness).

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

@testset "Test FileExchangeCtrl.decryptFile" begin

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

    # ---------------------------------------------------------------- sidecar method

    @testset "decryptFile(filePath; sideCarFilePath) reads the ref from childKeyRef:" begin
        mktempdir() do dir
            plaintext = "sidecar-plaintext-$(uuid4())"
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, plaintext)

            # The decryptFile sidecar branch parses the ref as an Int, then passes
            # it as the gpg passphrase. We encrypt with the same value (a string
            # that matches the parsed integer) so the round-trip works.
            refStr     = "42"
            encryptedPath = _gpgEncrypt(inputPath, refStr)
            sidecarPath   = _writeSidecar(dir, "childKeyRef: $refStr\n")

            decryptedPath = FileExchangeCtrl.decryptFile(
                encryptedPath; sideCarFilePath = sidecarPath,
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
    end

    @testset "decryptFile(filePath; sideCarFilePath) supports all key/separator variants" begin
        # The supported variants come from the regex in extractKdfChildKeyRefFromSidecarFile.
        cases = [
            "childKeyRef:7",
            "childKeyRef=7",
            "child_key_ref:7",
            "child_key_ref=7",
            "keyRef:7",
            "keyRef=7",
            "key_ref:7",
            "key_ref=7",
            "CHILDKEYREF:7",
            "ChildKeyRef=7",
            "childKeyRef:   7",
            "childKeyRef = 7",
        ]
        for sidecarContents in cases
            mktempdir() do dir
                plaintext = "variant-$(uuid4())"
                inputPath = joinpath(dir, "plain.txt")
                write(inputPath, plaintext)

                refStr       = "7"
                encryptedPath = _gpgEncrypt(inputPath, refStr)
                sidecarPath   = _writeSidecar(dir, sidecarContents)

                decryptedPath = FileExchangeCtrl.decryptFile(
                    encryptedPath; sideCarFilePath = sidecarPath,
                )

                try
                    @test read(decryptedPath, String) == plaintext
                finally
                    rm(encryptedPath; force = true)
                    rm(decryptedPath; force = true)
                    rm(sidecarPath;   force = true)
                end
            end
        end
    end

    @testset "decryptFile(filePath; sideCarFilePath) works when sidecar is embedded in larger text" begin
        mktempdir() do dir
            plaintext = "embedded-$(uuid4())"
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, plaintext)

            refStr       = "1234"
            encryptedPath = _gpgEncrypt(inputPath, refStr)
            sidecarContents = string(
                "# sidecar metadata\n",
                "checksum: deadbeef\n",
                "childKeyRef=$refStr\n",
                "uploadedAt: 2026-01-01T00:00:00Z\n",
            )
            sidecarPath = _writeSidecar(dir, sidecarContents)

            decryptedPath = FileExchangeCtrl.decryptFile(
                encryptedPath; sideCarFilePath = sidecarPath,
            )

            try
                @test read(decryptedPath, String) == plaintext
            finally
                rm(encryptedPath; force = true)
                rm(decryptedPath; force = true)
                rm(sidecarPath;   force = true)
            end
        end
    end

    @testset "decryptFile(filePath; sideCarFilePath) errors on missing sidecar file" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "anything")

            encryptedPath = _gpgEncrypt(inputPath, "any-pwd")
            missingSidecar = joinpath(dir, "no-such-sidecar.txt")

            try
                @test_throws SystemError FileExchangeCtrl.decryptFile(
                    encryptedPath; sideCarFilePath = missingSidecar,
                )
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "decryptFile(filePath; sideCarFilePath) errors when sidecar has no matching key" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "anything")

            encryptedPath = _gpgEncrypt(inputPath, "any-pwd")
            sidecarPath   = _writeSidecar(dir, "no relevant line in here\n")

            try
                @test_throws ErrorException FileExchangeCtrl.decryptFile(
                    encryptedPath; sideCarFilePath = sidecarPath,
                )
            finally
                rm(encryptedPath; force = true)
                rm(sidecarPath;   force = true)
            end
        end
    end

    @testset "decryptFile(filePath; sideCarFilePath) errors when the underlying gpg decrypt fails" begin
        # Sidecar is valid and parses to a ref, but the ref-as-passphrase does
        # not match the passphrase the file was actually encrypted with.
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "secret-$(uuid4())")

            encryptedPath = _gpgEncrypt(inputPath, "actual-pwd")
            sidecarPath   = _writeSidecar(dir, "childKeyRef: 99\n")  # parses to 99

            try
                @test_throws ProcessFailedException FileExchangeCtrl.decryptFile(
                    encryptedPath; sideCarFilePath = sidecarPath,
                )
            finally
                rm(encryptedPath; force = true)
                rm(sidecarPath;   force = true)
            end
        end
    end
end

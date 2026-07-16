include("__prerequisite.jl")

# Helper: decrypt a gpg-encrypted file with the given passphrase and return the
# plaintext. Uses the same gpg invocation shape as `FileExchangeCtrl.decryptFile`
# so we don't have to depend on decryptFile being correct in this test.
function _gpgDecrypt(encryptedFilePath::String, cryptPwd::String)::String
    mktempdir() do dir
        out = joinpath(dir, "out.txt")
        run(pipeline(
            `gpg --batch --yes --passphrase $cryptPwd --decrypt $encryptedFilePath`,
            stdout = out,
            stderr = devnull,
        ))
        return read(out, String)
    end
end

@testset "Test FileExchangeCtrl.encryptFile" begin

    @testset "Encrypts a small text file and round-trips with the same passphrase" begin
        mktempdir() do dir
            plaintext      = "hello world $(uuid4())\n"
            inputPath      = joinpath(dir, "plain.txt")
            write(inputPath, plaintext)

            encryptedPath = FileExchangeCtrl.encryptFile(inputPath, "test-pwd-1234")

            try
                # Returned path is a real file, distinct from the input.
                @test encryptedPath != inputPath
                @test isfile(encryptedPath)
                @test filesize(encryptedPath) > 0

                # Decrypting with the same passphrase recovers the original content.
                decrypted = _gpgDecrypt(encryptedPath, "test-pwd-1234")
                @test decrypted == plaintext
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Encrypted output is not the plaintext" begin
        mktempdir() do dir
            plaintext = "secret-content-$(uuid4())"
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, plaintext)

            encryptedPath = FileExchangeCtrl.encryptFile(inputPath, "test-pwd-1234")

            try
                # The encrypted file should not contain the plaintext in raw form.
                encryptedBytes = read(encryptedPath)
                @test isnothing(findfirst(
                    Vector{UInt8}(codeunits(plaintext)), encryptedBytes,
                ))
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Wrong passphrase cannot decrypt the output" begin
        mktempdir() do dir
            plaintext = "another-secret-$(uuid4())"
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, plaintext)

            encryptedPath = FileExchangeCtrl.encryptFile(inputPath, "correct-pwd")

            try
                @test_throws ProcessFailedException _gpgDecrypt(encryptedPath, "wrong-pwd")
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Encrypts binary content" begin
        mktempdir() do dir
            # Random bytes so we can't accidentally match on a gpg header.
            binary = rand(UInt8, 4096)
            inputPath = joinpath(dir, "blob.bin")
            write(inputPath, binary)

            encryptedPath = FileExchangeCtrl.encryptFile(inputPath, "bin-pwd")

            try
                mktempdir() do outDir
                    out = joinpath(outDir, "blob.dec")
                    run(pipeline(
                        `gpg --batch --yes --passphrase bin-pwd --decrypt $encryptedPath`,
                        stdout = out,
                        stderr = devnull,
                    ))
                    @test read(out) == binary
                end
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Encrypts a larger file" begin
        mktempdir() do dir
            # 1 MiB of pseudo-random data; well above any "tiny file" edge case.
            big = rand(UInt8, 1024 * 1024)
            inputPath = joinpath(dir, "big.bin")
            write(inputPath, big)

            encryptedPath = FileExchangeCtrl.encryptFile(inputPath, "big-pwd")

            try
                @test isfile(encryptedPath)
                @test filesize(encryptedPath) > 0
                @test filesize(encryptedPath) != filesize(inputPath)

                mktempdir() do outDir
                    out = joinpath(outDir, "big.dec")
                    run(pipeline(
                        `gpg --batch --yes --passphrase big-pwd --decrypt $encryptedPath`,
                        stdout = out,
                        stderr = devnull,
                    ))
                    @test read(out) == big
                end
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Encrypts an empty file" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "empty.txt")
            write(inputPath, "")

            encryptedPath = FileExchangeCtrl.encryptFile(inputPath, "empty-pwd")

            try
                @test isfile(encryptedPath)
                # gpg produces a small header + checksum even for empty input.
                @test filesize(encryptedPath) > 0

                decrypted = _gpgDecrypt(encryptedPath, "empty-pwd")
                @test decrypted == ""
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Returned path lives under the system temp directory when useSourceFileName=false" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "locate me")

            encryptedPath = FileExchangeCtrl.encryptFile(
                inputPath,
                "locate-pwd",
                ;useSourceFileName = false,
            )

            try
                # With `useSourceFileName=false` the file is created via
                # `tempname()` and lives under the system temp directory.
                @test isfile(encryptedPath)
                @test startswith(realpath(dirname(encryptedPath)), realpath(tempdir()))
                @test dirname(encryptedPath) != dir
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Returned path mirrors source location and name by default (useSourceFileName=true)" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "side-by-side")

            encryptedPath = FileExchangeCtrl.encryptFile(inputPath, "side-pwd")

            try
                # Default behaviour: the encrypted file lives in the same
                # directory as the source and shares its basename plus a
                # `.gpg` extension.
                @test dirname(encryptedPath) == dir
                @test basename(encryptedPath) == "plain.txt.gpg"
                @test endswith(encryptedPath, ".gpg")
                @test isfile(encryptedPath)
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Returned path mirrors source location and name when useSourceFileName=true is explicit" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "nested-name.bin")
            write(inputPath, "explicit-flag")

            encryptedPath = FileExchangeCtrl.encryptFile(
                inputPath,
                "explicit-pwd",
                ;useSourceFileName = true,
            )

            try
                # Passing `useSourceFileName=true` explicitly should produce
                # the same output as relying on the default.
                @test dirname(encryptedPath) == dir
                @test basename(encryptedPath) == "nested-name.bin.gpg"
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Returned path uses tempname() and lives under tempdir when useSourceFileName=false" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "remote")

            encryptedPath = FileExchangeCtrl.encryptFile(
                inputPath,
                "remote-pwd",
                ;useSourceFileName = false,
            )

            try
                # With `useSourceFileName=false` the file is created under
                # `tempdir()` and uses a `tempname()`-generated basename, so
                # it does not collide with the source.
                @test startswith(realpath(dirname(encryptedPath)), realpath(tempdir()))
                @test dirname(encryptedPath) != dir
                @test basename(encryptedPath) != "plain.txt.gpg"
                @test endswith(encryptedPath, ".gpg")
                @test isfile(encryptedPath)
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Returned path has a .gpg extension" begin
        mktempdir() do dir
            inputPath = joinpath(dir, "plain.txt")
            write(inputPath, "extension-check")

            encryptedPath = FileExchangeCtrl.encryptFile(inputPath, "ext-pwd")

            try
                # The output file is gpg-encrypted; surface that in the
                # filename so it is recognised by external tooling and
                # round-trips cleanly with FileExchangeCtrl.decryptFile.
                @test endswith(encryptedPath, ".gpg")
                @test isfile(encryptedPath)
            finally
                rm(encryptedPath; force = true)
            end
        end
    end

    @testset "Errors when the input file does not exist" begin
        mktempdir() do dir
            missingPath = joinpath(dir, "does-not-exist.txt")
            # gpg exits non-zero when the input file is missing; `run` rethrows
            # that as a ProcessFailedException.
            @test_throws ProcessFailedException FileExchangeCtrl.encryptFile(
                missingPath, "any-pwd"
            )
        end
    end
end

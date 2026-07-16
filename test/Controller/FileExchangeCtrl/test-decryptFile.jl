include("__prerequisite.jl")

# Helper for setting up encrypted fixtures without depending on
# FileExchangeCtrl.encryptFile (keeps this test independent of its correctness).

function _gpgEncrypt(plaintextPath::String, cryptPwd::String)::String
    out = tempname() * ".gpg"
    run(pipeline(
        `gpg --batch --yes --passphrase $cryptPwd --output $out --symmetric $plaintextPath`,
        stderr = devnull,
    ))
    return out
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
end

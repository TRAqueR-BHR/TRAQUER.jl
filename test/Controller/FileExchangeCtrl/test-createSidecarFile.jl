include("__prerequisite.jl")

@testset "Test FileExchangeCtrl.createSidecarFile" begin

    @testset "Writes a single-line 'key_ref=<value>' file" begin
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            FileExchangeCtrl.createSidecarFile(path, 42)

            @test isfile(path)
            contents = read(path, String)
            @test contents == "key_ref=42\n"
        end
    end

    @testset "Round-trips with extractKdfChildKeyRefFromSidecarFile" begin
        # The value written by `createSidecarFile` must be parseable by the
        # downstream extractor. This is the contract that ties the two
        # functions together.
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            FileExchangeCtrl.createSidecarFile(path, 1234)

            ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
            @test ref == 1234
            @test ref isa Int
        end
    end

    @testset "Handles edge-case values" begin
        cases = [
            (0,     "key_ref=0\n"),
            (1,     "key_ref=1\n"),
            (32767, "key_ref=32767\n"),  # max Int16
            (-1,    "key_ref=-1\n"),     # negative values are written verbatim
        ]
        for (keyRef, expectedContents) in cases
            mktempdir() do dir
                path = joinpath(dir, "sidecar.txt")
                FileExchangeCtrl.createSidecarFile(path, keyRef)

                contents = read(path, String)
                @test contents == expectedContents
            end
        end
    end

    @testset "Overwrites an existing file" begin
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "stale content that should be replaced\n")

            FileExchangeCtrl.createSidecarFile(path, 7)

            @test read(path, String) == "key_ref=7\n"
        end
    end

    @testset "Creates the file in any writable directory" begin
        # The function does not constrain where the file lives; only the
        # parent directory needs to exist and be writable.
        mktempdir() do dir
            nested = joinpath(dir, "a", "b", "c")
            mkpath(nested)
            path = joinpath(nested, "sidecar.txt")

            FileExchangeCtrl.createSidecarFile(path, 99)

            @test isfile(path)
            @test read(path, String) == "key_ref=99\n"
        end
    end

    @testset "Errors when the parent directory does not exist" begin
        mktempdir() do dir
            missingDir = joinpath(dir, "does-not-exist")
            path = joinpath(missingDir, "sidecar.txt")

            # `write` raises a SystemError when it cannot create the file
            # because a parent directory is missing.
            @test_throws SystemError FileExchangeCtrl.createSidecarFile(path, 1)
        end
    end

    @testset "Returned value is nothing" begin
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            result = FileExchangeCtrl.createSidecarFile(path, 5)
            @test result === nothing
        end
    end

end

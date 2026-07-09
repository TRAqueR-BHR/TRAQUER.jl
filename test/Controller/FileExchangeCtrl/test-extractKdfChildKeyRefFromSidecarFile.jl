include("__prerequisite.jl")

@testset "Test FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile" begin

    # Helper: write `contents` to a fresh file inside a temp dir and return its path.
    function writeSidecarFile(contents::String)::String
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, contents)
            # mktempdir cleans up after the do-block; copy the file out so it survives
            # until the test that created it has read it. We just return the path and
            # rely on the parent test's mktempdir to manage lifetime.
            return path
        end
    end

    @testset "Supported keys and separators" begin
        # All 8 combinations: 4 key names × 2 separators.
        cases = [
            ("childKeyRef:42",   42),
            ("childKeyRef=42",   42),
            ("child_key_ref:42", 42),
            ("child_key_ref=42", 42),
            ("keyRef:42",        42),
            ("keyRef=42",        42),
            ("key_ref:42",       42),
            ("key_ref=42",       42),
        ]
        for (contents, expected) in cases
            mktempdir() do dir
                path = joinpath(dir, "sidecar.txt")
                write(path, contents)
                ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
                @test ref == expected
            end
        end
    end

    @testset "Case insensitivity" begin
        cases = [
            ("CHILDKEYREF:7",    7),
            ("ChildKeyRef:7",    7),
            ("CHILD_KEY_REF=7",  7),
            ("KeyRef:7",         7),
            ("KEY_REF=7",        7),
        ]
        for (contents, expected) in cases
            mktempdir() do dir
                path = joinpath(dir, "sidecar.txt")
                write(path, contents)
                ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
                @test ref == expected
            end
        end
    end

    @testset "Whitespace tolerance around the separator" begin
        cases = [
            ("childKeyRef:42",   42),   # no whitespace
            ("childKeyRef: 42",  42),   # one space
            ("childKeyRef:   42", 42),  # multiple spaces
            ("childKeyRef:\t42", 42),   # tab
            ("childKeyRef = 42", 42),   # spaces around '='
            ("childKeyRef  =  42", 42), # lots of spaces
        ]
        for (contents, expected) in cases
            mktempdir() do dir
                path = joinpath(dir, "sidecar.txt")
                write(path, contents)
                ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
                @test ref == expected
            end
        end
    end

    @testset "Embedded inside larger content" begin
        # Single line surrounded by other text.
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "some preamble text childKeyRef: 99 trailing words")
            ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
            @test ref == 99
        end

        # Multi-line file with the ref on the second line.
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, string(
                "# sidecar metadata\n",
                "checksum: abcdef0123456789\n",
                "childKeyRef=1234\n",
                "uploadedAt: 2026-01-01T00:00:00Z\n",
            ))
            ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
            @test ref == 1234
        end
    end

    @testset "Return type and value range" begin
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "childKeyRef: 0")
            ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
            @test ref === 0
            @test ref isa Int
        end

        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "childKeyRef: 32767") # max Int16
            ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
            @test ref == 32767
        end
    end

    @testset "First match wins when multiple refs are present" begin
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "childKeyRef: 11\nkeyRef: 22\n")
            ref = FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path)
            @test ref == 11
        end
    end

    @testset "Errors when no matching pattern is found" begin
        # No recognisable key name, just digits.
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "some other content without a ref")
            @test_throws ErrorException FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(
                path
            )
        end

        # Recognisable key name but no digit after it.
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "childKeyRef: not-a-number")
            @test_throws ErrorException FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(
                path
            )
        end

        # Empty file.
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "")
            @test_throws ErrorException FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(
                path
            )
        end
    end

    @testset "Errors when the sidecar file does not exist" begin
        mktempdir() do dir
            missingPath = joinpath(dir, "does-not-exist.txt")
            @test_throws SystemError FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(
                missingPath
            )
        end
    end

    @testset "cryptPwd parameter is not consulted" begin
        # The function signature requires a cryptPwd but never uses it; the value
        # passed (or missing-like sentinels) must not affect the parsed ref.
        mktempdir() do dir
            path = joinpath(dir, "sidecar.txt")
            write(path, "childKeyRef: 5")
            @test FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path, "") == 5
            @test FileExchangeCtrl.extractKdfChildKeyRefFromSidecarFile(path, "some-pwd") == 5
        end
    end
end

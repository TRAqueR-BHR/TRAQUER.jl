include("__prerequisite.jl")

@testset "Test FileExchangeCtrl.parseFileURL" begin

    @testset "s3:// URLs" begin

        @testset "parses a basic s3 URL" begin
            result = FileExchangeCtrl.parseFileURL("s3://my-bucket/path/to/file.xml")
            @test result.scheme === :s3
            @test result.bucket == "my-bucket"
            @test result.key == "path/to/file.xml"
            @test result.localPath == ""
        end

        @testset "parses an s3 URL with a single-segment key" begin
            result = FileExchangeCtrl.parseFileURL("s3://bucket/file.xml")
            @test result.scheme === :s3
            @test result.bucket == "bucket"
            @test result.key == "file.xml"
            @test result.localPath == ""
        end

        @testset "parses an s3 URL with deeply nested key" begin
            result = FileExchangeCtrl.parseFileURL(
                "s3://my-bucket/a/b/c/d/e/f.xml",
            )
            @test result.scheme === :s3
            @test result.bucket == "my-bucket"
            @test result.key == "a/b/c/d/e/f.xml"
            @test result.localPath == ""
        end

        @testset "parses an s3 URL with trailing slash" begin
            result = FileExchangeCtrl.parseFileURL("s3://bucket/")
            @test result.scheme === :s3
            @test result.bucket == "bucket"
            @test result.key == ""
            @test result.localPath == ""
        end

        @testset "errors when s3 URL has no key (no slash)" begin
            @test_throws ArgumentError FileExchangeCtrl.parseFileURL("s3://bucket")
        end

        @testset "errors when s3 URL has no key (just scheme)" begin
            @test_throws ArgumentError FileExchangeCtrl.parseFileURL("s3://")
        end

        @testset "errors when s3 URL has empty bucket name" begin
            @test_throws ArgumentError FileExchangeCtrl.parseFileURL("s3:///key")
        end

    end

    @testset "file:// URLs" begin

        @testset "parses an absolute file URL" begin
            result = FileExchangeCtrl.parseFileURL("file:///tmp/file.xml")
            @test result.scheme === :file
            @test result.bucket == ""
            @test result.key == ""
            @test result.localPath == "/tmp/file.xml"
        end

        @testset "parses a file URL with a relative path" begin
            result = FileExchangeCtrl.parseFileURL("file://relative/path/file.xml")
            @test result.scheme === :file
            @test result.bucket == ""
            @test result.key == ""
            @test result.localPath == "relative/path/file.xml"
        end

        @testset "parses a file URL pointing at a file in the current dir" begin
            result = FileExchangeCtrl.parseFileURL("file://file.xml")
            @test result.scheme === :file
            @test result.localPath == "file.xml"
        end

        @testset "parses a file URL with empty path" begin
            # file:// with no further characters → empty local path. Callers are
            # responsible for handling this case (e.g. by checking isfile).
            result = FileExchangeCtrl.parseFileURL("file://")
            @test result.scheme === :file
            @test result.localPath == ""
        end

    end

    @testset "Unsupported schemes" begin

        @testset "errors on http:// URLs" begin
            @test_throws ArgumentError FileExchangeCtrl.parseFileURL(
                "http://example.com/file.xml",
            )
        end

        @testset "errors on https:// URLs" begin
            @test_throws ArgumentError FileExchangeCtrl.parseFileURL(
                "https://example.com/file.xml",
            )
        end

        @testset "errors on raw filesystem paths" begin
            @test_throws ArgumentError FileExchangeCtrl.parseFileURL("/tmp/file.xml")
        end

        @testset "errors on the empty string" begin
            @test_throws ArgumentError FileExchangeCtrl.parseFileURL("")
        end

    end

    @testset "Return type" begin

        @testset "returns a NamedTuple with the expected shape" begin
            result = FileExchangeCtrl.parseFileURL("s3://b/k")
            @test result isa NamedTuple
            @test propertynames(result) == (:scheme, :bucket, :key, :localPath)
            @test result.scheme isa Symbol
            @test result.bucket isa String
            @test result.key isa String
            @test result.localPath isa String
        end

    end

end

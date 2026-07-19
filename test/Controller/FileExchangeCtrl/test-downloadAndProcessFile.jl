include("__prerequisite.jl")

@testset "Test FileExchangeCtrl.downloadAndProcessFile" begin

    rootDir = "custom/demo/test/sample-input-data/accidental_discovery_and_epidemic/"

    # Prepare the
    # Declare the input stays and analyses Excel file paths and the output XML file path
    staysExcelFilePath = joinpath(rootDir, "demo-stays SALIOU.XLSX")
    analysisExcelFilePath = joinpath(rootDir, "demo-analyses SALIOU.XLSX")
    xmlOutputFilePath = joinpath(rootDir, "demo-fhir SALIOU.xml")
    fhir_output = ETLCtrl.Excel.convertExcelToFHIR(
        staysExcelFilePath, analysisExcelFilePath, xmlOutputFilePath
    )
    MasterKeyCtrl.setMasterKey(_TestUtils.getDefaultMasterKeyWords())

    @testset "Test FileExchangeCtrl.downloadAndProcessFile - case fs:" begin

        # Get the child key ref and value
        refAndChildKey::NamedTuple{(:ref, :childKeyHex), Tuple{Int16, String}} =
            TRAQUERUtil.createDBConnAndExecute() do dbconn
                # Get child encryption key
                FileExchangeCtrl.getKdfChildKey(
                    dbconn
                )
            end

        # Crypt the file
        cryptFilePath  = FileExchangeCtrl.encryptFile(
            xmlOutputFilePath,
            refAndChildKey.childKeyHex,
            true, # use the same dir and source file name for the encrypted file (+ .gpg)
        )

        # Move the file to the pending directory
        cryptFilePathInPendingDir = joinpath(Conf.getFSPendingInputFilesDir(), basename(cryptFilePath))
        sidecarFilePathInPendingDir = cryptFilePathInPendingDir * ".sidecar"
        mv(
            cryptFilePath,
            cryptFilePathInPendingDir
        )

        # Create the sidecar file in the pending directory
        FileExchangeCtrl.createSidecarFile(
            sidecarFilePathInPendingDir,
            refAndChildKey.ref
        )

        # Call the endpoint
        TRAQUERUtil.createDBConnAndExecute() do dbconn
            FileExchangeCtrl.downloadAndProcessFile(
                "file://$cryptFilePathInPendingDir",
                dbconn
                ;alsoProcessNewlyIntegratedData = false)
        end

    end

    @testset "Test FileExchangeCtrl.downloadAndProcessFile - case s3:" begin
    end



end

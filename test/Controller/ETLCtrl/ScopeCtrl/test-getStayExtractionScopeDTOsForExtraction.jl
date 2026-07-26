include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.getStayExtractionScopeDTOsForExtraction" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        encryptionStr = _TestUtils.getDefaultEncryptionStr()
        ETLCtrl.ScopeCtrl.getStayExtractionScopeDTOsForExtraction(
            encryptionStr,
            dbconn,
        )
    end
end

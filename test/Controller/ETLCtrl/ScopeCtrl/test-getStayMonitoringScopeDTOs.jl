include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.getStayMonitoringScopeDTOs" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        encryptionStr = _TestUtils.getDefaultEncryptionStr()
        ETLCtrl.ScopeCtrl.getStayMonitoringScopeDTOs(
            encryptionStr,
            dbconn,
        )
    end
end

include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        ETLCtrl.ScopeCtrl.refreshStayMonitoringScopes(dbconn)
    end
end

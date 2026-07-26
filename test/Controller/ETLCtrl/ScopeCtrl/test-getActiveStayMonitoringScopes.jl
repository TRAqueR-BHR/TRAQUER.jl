include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.getActiveStayMonitoringScopes" begin
    TRAQUERUtil.createDBConnAndExecute() do dbconn
        activeStayMonitoringScopes = ETLCtrl.ScopeCtrl.getActiveStayMonitoringScopes(dbconn)
        @test activeStayMonitoringScopes isa Vector{StayMonitoringScope}
    end
end

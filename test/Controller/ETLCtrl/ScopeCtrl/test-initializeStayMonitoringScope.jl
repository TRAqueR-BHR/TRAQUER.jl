include("__prerequisite.jl")

@testset "Test ETLCtrl.ScopeCtrl.initializeStayMonitoringScope" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        infectiousStatus = InfectiousStatus(
            infectiousStatus = InfectiousStatusType.not_at_risk,
        )
        @test isnothing(
            ETLCtrl.ScopeCtrl.initializeStayMonitoringScope(infectiousStatus, dbconn)
        )
    end


end

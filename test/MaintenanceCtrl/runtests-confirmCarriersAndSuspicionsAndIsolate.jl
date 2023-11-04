include("../runtests-prerequisite.jl")

@testset "Test MaintenanceCtrl.confirmCarriersAndSuspicionsAndIsolate" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        MaintenanceCtrl.confirmCarriersAndSuspicionsAndIsolate(
            dbconn
            ;simulate = false
        )
    end

end

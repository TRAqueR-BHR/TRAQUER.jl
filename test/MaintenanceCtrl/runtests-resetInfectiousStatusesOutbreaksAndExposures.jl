include("../runtests-prerequisite.jl")

@testset "MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        TRAQUER.MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures(dbconn)
    end

end

include("../runtests-prerequisite.jl")

@testset "MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        TRAQUER.MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures(dbconn)
    end

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        TRAQUER.MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposures(
            Patient(id = "412f6de9-776a-4fff-b429-3cf53a390127"),
            dbconn
        )
    end

end

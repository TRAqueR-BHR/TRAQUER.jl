include("../runtests-prerequisite.jl")

@testset "MaintenanceCtrl.resetProcessingTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        TRAQUER.MaintenanceCtrl.resetProcessingTime(
            Patient(id = "412f6de9-776a-4fff-b429-3cf53a390127"),
            dbconn
        )
    end

end

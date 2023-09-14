include("../runtests-prerequisite.jl")

@testset "MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposuresAndReprocessPatientData" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        TRAQUER.MaintenanceCtrl.resetInfectiousStatusesOutbreaksAndExposuresAndReprocessPatientData(
            Patient(id = "412f6de9-776a-4fff-b429-3cf53a390127"),
            dbconn
            ;forceProcessingTime = ZonedDateTime(
                DateTime("2023-01-20"),
                TRAQUERUtil.getTimeZone()
            )
        )
    end

end

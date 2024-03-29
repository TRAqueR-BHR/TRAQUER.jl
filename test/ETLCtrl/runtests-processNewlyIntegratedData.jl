include("../runtests-prerequisite.jl")

@testset "Test ETLCtrl.processNewlyIntegratedData" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        ETLCtrl.processNewlyIntegratedData(dbconn)
    end

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        ETLCtrl.processNewlyIntegratedData(
            dbconn
            ;patient = Patient(id = "412f6de9-776a-4fff-b429-3cf53a390127"),
            forceProcessingTime = ZonedDateTime(
                DateTime("2023-01-20"),
                TRAQUERUtil.getTimeZone()
            )
        )
    end

end

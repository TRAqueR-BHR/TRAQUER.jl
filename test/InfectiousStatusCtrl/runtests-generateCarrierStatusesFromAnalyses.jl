include("../runtests-prerequisite.jl")

@testset "Test InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses" begin

    TRAQUERUtil.createDBConnAndExecuteWithTransaction() do dbconn
        patient = Patient(id = "f553105d-5315-4fe7-8405-989113f9647e")
        InfectiousStatusCtrl.generateCarrierStatusesFromAnalyses(
            patient,
            (
                ZonedDateTime(DateTime("2022-12-01T12:19"), TRAQUERUtil.getTimeZone()),
                ZonedDateTime(DateTime("2022-12-16T12:19"), TRAQUERUtil.getTimeZone())
            ),
            dbconn)
    end

end

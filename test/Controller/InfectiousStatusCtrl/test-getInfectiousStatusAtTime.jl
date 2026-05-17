include("__prerequisite.jl")
@testset "Test InfectiousStatusCtrl.getInfectiousStatusAtTime" begin

    dbconn = TRAQUERUtil.openDBConn()

    patient = Patient(id = "412f6de9-776a-4fff-b429-3cf53a390127")

    infectiousStatus = InfectiousStatusCtrl.getInfectiousStatusAtTime(
        patient,
        InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae,
        ZonedDateTime(DateTime("2023-01-08T17:00:00"), TRAQUERUtil.getTimeZone()),
        false, # retrieveComplexProps::Bool,
        dbconn
        ;statusesOfInterest = missing
    )

    @info "infectiousStatus.id[$(infectiousStatus.id)] infectiousStatus.refTime[$(infectiousStatus.refTime)]"

    TRAQUERUtil.closeDBConn(dbconn)

end

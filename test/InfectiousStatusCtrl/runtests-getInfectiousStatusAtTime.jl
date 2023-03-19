include("../runtests-prerequisite.jl")

@testset "Test InfectiousStatusCtrl.getInfectiousStatusAtTime" begin

    dbconn = TRAQUERUtil.openDBConn()


    patient = PatientCtrl.retrievePatientsFromLastname(
        "O",
        getDefaultEncryptionStr(),
        dbconn) |> first

    infectiousStatus = InfectiousStatusCtrl.getInfectiousStatusAtTime(
        patient,
        ZonedDateTime(DateTime("2022-05-08T17:00:00"), TRAQUERUtil.getTimeZone()),
        false, # retrieveComplexProps::Bool,
        dbconn
        ;statusesOfInterest = missing
    )

    @info "infectiousStatus.id[$(infectiousStatus.id)] infectiousStatus.refTime[$(infectiousStatus.refTime)]"

    TRAQUERUtil.closeDBConn(dbconn)
end

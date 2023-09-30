include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.fixMissingHospitalizationOutTime" begin

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.fixMissingHospitalizationOutTime(
            Patient(id = "31e4246f-d4a8-428b-8d3a-26029e87e67f"),
            dbconn
            ;simulate = false
        )
    end

end

@testset "Test StayCtrl.fixMissingHospitalizationOutTime" begin

    # Case two stays with same hospitalizationInTime, first stay is missing its
    # hospitalizationOutTime and second stay has an hospitalizationOutTime
    stays = [
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = missing,
            inTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
        ),
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = ZonedDateTime(DateTime("2023-09-12T13:00"), TRAQUERUtil.getTimeZone()),
            inTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-12T13:00"), TRAQUERUtil.getTimeZone()),
        )
    ]

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.fixMissingHospitalizationOutTime(stays, dbconn ;simulate = true)
    end

    for (idx,stay) in enumerate(stays)
        @info "stay[$idx] hospitalizationOutTime[$(stay.hospitalizationOutTime)]"
    end
    @test stays[1].hospitalizationOutTime == stays[2].hospitalizationOutTime

    # Case two stays with different hospitalizationInTime, first stay is missing its
    # hospitalizationOutTime and second stay has an hospitalizationOutTime
    stays = [
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-08-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = missing,
            inTime = ZonedDateTime(DateTime("2023-08-01T13:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
        ),
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = ZonedDateTime(DateTime("2023-09-12T13:00"), TRAQUERUtil.getTimeZone()),
            inTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-12T13:00"), TRAQUERUtil.getTimeZone()),
        )
    ]

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.fixMissingHospitalizationOutTime(stays, dbconn ;simulate = true)
    end

    for (idx,stay) in enumerate(stays)
        @info "stay[$idx] hospitalizationOutTime[$(stay.hospitalizationOutTime)]"
    end
    @test stays[1].hospitalizationOutTime == stays[1].outTime

    # Case two stays with different hospitalizationInTime, first stay is missing its
    # hospitalizationOutTime and has no outTime
    stays = [
        Stay(
            id = "stay1",
            hospitalizationInTime = ZonedDateTime(DateTime("2023-08-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = missing,
            inTime = ZonedDateTime(DateTime("2023-08-01T13:00"), TRAQUERUtil.getTimeZone()),
            outTime = missing,
        ),
        Stay(
            id = "stay2",
            hospitalizationInTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = ZonedDateTime(DateTime("2023-09-12T13:00"), TRAQUERUtil.getTimeZone()),
            inTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-12T13:00"), TRAQUERUtil.getTimeZone()),
        )
    ]

    @test_throws "Problem while trying to fix missing hospitalizationOutTime" TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.fixMissingHospitalizationOutTime(stays, dbconn ;simulate = true)
    end

    # Case two stays with different hospitalizationInTime, first stay is missing its
    # hospitalizationOutTime and second stay has no hospitalizationOutTime
    stays = [
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-08-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = missing,
            inTime = ZonedDateTime(DateTime("2023-08-01T13:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
        ),
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = missing,
            inTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
            outTime = missing,
        )
    ]

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.fixMissingHospitalizationOutTime(stays, dbconn ;simulate = true)
    end

    for (idx,stay) in enumerate(stays)
        @info "stay[$idx] hospitalizationOutTime[$(stay.hospitalizationOutTime)]"
    end
    @test stays[1].hospitalizationOutTime === stays[1].outTime


    # Case three stays with same hospitalizationInTime, first and second stays are missing
    # their hospitalizationOutTime and third stay has an hospitalizationOutTime
    stays = [
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = missing,
            inTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
        ),
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = missing,
            inTime = ZonedDateTime(DateTime("2023-09-01T19:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-01T20:00"), TRAQUERUtil.getTimeZone()),
        ),
        Stay(
            hospitalizationInTime = ZonedDateTime(DateTime("2023-09-01T13:00"), TRAQUERUtil.getTimeZone()),
            hospitalizationOutTime = ZonedDateTime(DateTime("2023-09-12T13:00"), TRAQUERUtil.getTimeZone()),
            inTime = ZonedDateTime(DateTime("2023-09-01T20:00"), TRAQUERUtil.getTimeZone()),
            outTime = ZonedDateTime(DateTime("2023-09-12T13:00"), TRAQUERUtil.getTimeZone()),
        )
    ]

    TRAQUERUtil.createDBConnAndExecute() do dbconn
        StayCtrl.fixMissingHospitalizationOutTime(stays, dbconn ;simulate = true)
    end

    for (idx,stay) in enumerate(stays)
        @info "stay[$idx] hospitalizationOutTime[$(stay.hospitalizationOutTime)]"
    end
    @test stays[1].hospitalizationOutTime == stays[3].hospitalizationOutTime
    @test stays[2].hospitalizationOutTime == stays[3].hospitalizationOutTime

end

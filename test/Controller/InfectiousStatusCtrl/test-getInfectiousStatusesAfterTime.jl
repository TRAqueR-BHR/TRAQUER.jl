include("__prerequisite.jl")

@testset "Test InfectiousStatusCtrl.getInfectiousStatusesAfterTime" begin
    dbconn = TRAQUERUtil.openDBConnAndBeginTransaction()

    try
        patient = _TestUtils.createDummyPatient(
            dbconn;
            encryptionStr = _TestUtils.getDefaultEncryptionStr(),
        )
        baseTime = ZonedDateTime(now(), TRAQUERUtil.getTimeZone()) - Day(2)
        cpe = InfectiousAgentCategory.carbapenemase_producing_enterobacteriaceae
        vre = InfectiousAgentCategory.vancomycin_resistant_enterococcus

        InfectiousStatusCtrl.upsert!(
            InfectiousStatus(
                patient = patient,
                infectiousAgent = cpe,
                infectiousStatus = InfectiousStatusType.carrier,
                refTime = baseTime,
                isConfirmed = true,
            ),
            dbconn;
            createEventForStatus = false,
        )

        InfectiousStatusCtrl.upsert!(
            InfectiousStatus(
                patient = patient,
                infectiousAgent = cpe,
                infectiousStatus = InfectiousStatusType.not_at_risk,
                refTime = baseTime + Hour(1),
                isConfirmed = true,
            ),
            dbconn;
            createEventForStatus = false,
        )

        InfectiousStatusCtrl.upsert!(
            InfectiousStatus(
                patient = patient,
                infectiousAgent = vre,
                infectiousStatus = InfectiousStatusType.contact,
                refTime = baseTime + Hour(2),
                isConfirmed = true,
            ),
            dbconn;
            createEventForStatus = false,
        )

        InfectiousStatusCtrl.upsert!(
            InfectiousStatus(
                patient = patient,
                infectiousAgent = vre,
                infectiousStatus = InfectiousStatusType.carrier,
                refTime = baseTime + Hour(4),
                isConfirmed = true,
            ),
            dbconn;
            createEventForStatus = false,
        )

        # Get statuses after baseTime. For each agent, returns the closest status
        # after the time of interest: cpe.nar at +1h and vre.contact at +2h
        # (vre.carrier at +4h is farther from baseTime, so not returned)
        statusesAfterBaseTime = InfectiousStatusCtrl.getInfectiousStatusesAfterTime(
            patient,
            baseTime,
            false,
            dbconn,
        )
        @test length(statusesAfterBaseTime) == 3
        @test all(
            x -> x.refTime > baseTime,
            statusesAfterBaseTime,
        )

        # Get statuses after baseTime + 2h (excludes cpe.nar and vre.contact,
        # includes only vre.carrier at +4h)
        statusesAfterBasePlus2h = InfectiousStatusCtrl.getInfectiousStatusesAfterTime(
            patient,
            baseTime + Hour(2),
            false,
            dbconn,
        )
        @test length(statusesAfterBasePlus2h) == 1
        @test statusesAfterBasePlus2h[1].refTime == baseTime + Hour(4)
        @test statusesAfterBasePlus2h[1].infectiousAgent == vre

        # Filter to a single infectious agent of interest
        statusesAfterBaseTimeCpeOnly = InfectiousStatusCtrl.getInfectiousStatusesAfterTime(
            patient,
            baseTime,
            false,
            dbconn;
            infectiousAgentsOfInterest = [cpe],
        )
        @test length(statusesAfterBaseTimeCpeOnly) == 1
        @test statusesAfterBaseTimeCpeOnly[1].infectiousAgent == cpe

        # Filter to a single status type of interest
        statusesAfterBaseTimeCarriersOnly = InfectiousStatusCtrl.getInfectiousStatusesAfterTime(
            patient,
            baseTime,
            false,
            dbconn;
            statusesOfInterest = [InfectiousStatusType.carrier],
        )
        @test length(statusesAfterBaseTimeCarriersOnly) == 1
        @test statusesAfterBaseTimeCarriersOnly[1].infectiousStatus ==
            InfectiousStatusType.carrier

        # No statuses after the latest one
        statusesAfterLatest = InfectiousStatusCtrl.getInfectiousStatusesAfterTime(
            patient,
            baseTime + Hour(5),
            false,
            dbconn,
        )
        @test isempty(statusesAfterLatest)
    finally
        TRAQUERUtil.rollbackDBTransaction(dbconn)
        TRAQUERUtil.closeDBConn(dbconn)
    end
end

include("__prerequisite.jl")

@testset "Test InfectiousStatusCtrl.getInfectiousStatusesAtRiskForStayMonitoringScopeRefresh" begin
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

        InfectiousStatusCtrl.updateCurrentStatus(patient, dbconn)

        infectiousStatuses = InfectiousStatusCtrl.getInfectiousStatusesAtRiskForStayMonitoringScopeRefresh(dbconn)
        patientInfectiousStatuses = filter(
            x -> !ismissing(x.patient) && x.patient.id == patient.id,
            infectiousStatuses,
        )

        @test length(patientInfectiousStatuses) == 1
        @test all(x -> x.isCurrent === true, patientInfectiousStatuses)
        @test all(
            x -> x.infectiousStatus ∈ TRAQUER.INFECTIOUS_STATUS_TYPES_AT_RISK,
            patientInfectiousStatuses,
        )
        @test Set(
            (x.infectiousAgent, x.infectiousStatus) for x in patientInfectiousStatuses
        ) == Set([
            (vre, InfectiousStatusType.contact),
        ])
    finally
        TRAQUERUtil.rollbackDBTransaction(dbconn)
        TRAQUERUtil.closeDBConn(dbconn)
    end
end

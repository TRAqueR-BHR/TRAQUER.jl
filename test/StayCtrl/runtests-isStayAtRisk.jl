include("../runtests-prerequisite.jl")

@testset "Test StayCtrl.isStayAtRisk" begin

    # CASE 'Carrier refTime after the beginning of non-ending stay and no not_at_risk time'
    @test StayCtrl.isStayAtRisk(
        Stay(
            inTime = ZonedDateTime(DateTime("2022-04-11T02:00:00"), getTimeZone()),
            hospitalizationInTime = ZonedDateTime(DateTime("2022-04-11T02:00:00"), getTimeZone()),
            outTime = missing
        ),
        ZonedDateTime(DateTime("2022-04-11T02:30:00"), getTimeZone()), # carrierStatusRefTime::,
        missing ,# notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
    ) === true

    # CASE 'not_at_risk refTime before the beginning of non-ending stay'
    @test StayCtrl.isStayAtRisk(
        Stay(
            inTime = ZonedDateTime(DateTime("2022-05-11T02:00:00"), getTimeZone()),
            hospitalizationInTime = ZonedDateTime(DateTime("2022-05-11T02:00:00"), getTimeZone()),
            outTime = missing
        ),
        ZonedDateTime(DateTime("2022-04-11T01:30:00"), getTimeZone()), # carrierStatusRefTime::,
        ZonedDateTime(DateTime("2022-04-11T01:40:00"), getTimeZone()), # notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
    ) === false

    # CASE: TODO

end

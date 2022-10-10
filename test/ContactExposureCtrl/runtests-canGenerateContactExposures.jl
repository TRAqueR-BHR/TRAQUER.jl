include("../runtests-prerequisite.jl")

@testset "Test ContactExposureCtrl.canGenerateContactExposures" begin

    # CASE 'Carrier refTime after the beginning of non-ending stay and no not_at_risk time'
    @test ContactExposureCtrl.canGenerateContactExposures(
        Stay(
            inTime = ZonedDateTime(DateTime("2022-04-11T02:00:00"), getTimezone()),
            hospitalizationInTime = ZonedDateTime(DateTime("2022-04-11T02:00:00"), getTimezone()),
            outTime = missing
        ),
        ZonedDateTime(DateTime("2022-04-11T02:30:00"), getTimezone()), # carrierStatusRefTime::,
        missing ,# notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
    ) === true

    # CASE 'not_at_risk refTime before the beginning of non-ending stay'
    @test ContactExposureCtrl.canGenerateContactExposures(
        Stay(
            inTime = ZonedDateTime(DateTime("2022-05-11T02:00:00"), getTimezone()),
            hospitalizationInTime = ZonedDateTime(DateTime("2022-05-11T02:00:00"), getTimezone()),
            outTime = missing
        ),
        ZonedDateTime(DateTime("2022-04-11T01:30:00"), getTimezone()), # carrierStatusRefTime::,
        ZonedDateTime(DateTime("2022-04-11T01:40:00"), getTimezone()), # notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
    ) === false

    # CASE: TODO

end

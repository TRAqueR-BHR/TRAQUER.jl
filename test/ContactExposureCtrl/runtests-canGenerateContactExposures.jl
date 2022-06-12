include("../runtests-prerequisite.jl")

@testset "Test ContactExposureCtrl.canGenerateContactExposures" begin

    # CASE 'Carrier refTime after the beginning of non-ending stay and no not_at_risk time'
    ContactExposureCtrl.canGenerateContactExposures(
        Stay(
            inTime = ZonedDateTime(DateTime("2022-04-11T02:00:00"), getTimezone()),
            outTime = missing
        ),
        ZonedDateTime(DateTime("2022-04-11T02:30:00"), getTimezone()), # carrierStatusRefTime::,
        missing ,# notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
    )

    # CASE 'carrier refTime and not_at_risk refTime before the beginning of non-ending stay'
    ContactExposureCtrl.canGenerateContactExposures(
        Stay(
            inTime = ZonedDateTime(DateTime("2022-04-11T02:00:00"), getTimezone()),
            outTime = missing
        ),
        ZonedDateTime(DateTime("2022-04-11T01:30:00"), getTimezone()), # carrierStatusRefTime::,
        ZonedDateTime(DateTime("2022-04-11T01:40:00"), getTimezone()), # notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
    )

    # CASE: TODO

end

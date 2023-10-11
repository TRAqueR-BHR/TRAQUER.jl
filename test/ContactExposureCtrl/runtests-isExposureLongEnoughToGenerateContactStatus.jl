include("../runtests-prerequisite.jl")

@testset "Test ContactExposureCtrl.isExposureLongEnoughToGenerateContactStatus" begin

    startTime = now(getTimeZone())

    # Case where exposure duration is exactly the minimum allowed
    @test ContactExposureCtrl.isExposureLongEnoughToGenerateContactStatus(
        ContactExposure(
            startTime = startTime,
            endTime = startTime + Hour(4)
        )
        ;minimumExpositionDuration = Hour(4)
    ) === true

    # Case where exposure duration is less than minimum allowed
    @test ContactExposureCtrl.isExposureLongEnoughToGenerateContactStatus(
        ContactExposure(
            startTime = startTime,
            endTime = startTime + Hour(4) - Second(1)
        )
        ;minimumExpositionDuration = Hour(4)
    ) === false

    # Case where exposure duration is more than minimum allowed
    @test ContactExposureCtrl.isExposureLongEnoughToGenerateContactStatus(
        ContactExposure(
            startTime = startTime,
            endTime = startTime + Hour(4) + Second(1)
        )
        ;minimumExpositionDuration = Hour(4)
    ) === true


    # Case where we use the default value for 'minimumExpositionDuration'
    ContactExposureCtrl.isExposureLongEnoughToGenerateContactStatus(
        ContactExposure(
            startTime = startTime,
            endTime = startTime + Hour(4) + Second(1)
        )
    )

end

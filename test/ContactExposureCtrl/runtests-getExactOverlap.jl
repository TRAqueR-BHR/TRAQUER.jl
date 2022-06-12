include("../runtests-prerequisite.jl")

@testset "Test getExactOverlap()" begin

    ContactExposureCtrl.getExactOverlap(
        ZonedDateTime(now(),getTimezone()), # carrierStartTime::ZonedDateTime,
        missing, # carrierEndTime::Union{Missing, ZonedDateTime}
        ZonedDateTime(now(),getTimezone()),# contactStartTime::ZonedDateTime,
        missing, # ::Union{Missing, ZonedDateTime},
    ) |> first

end

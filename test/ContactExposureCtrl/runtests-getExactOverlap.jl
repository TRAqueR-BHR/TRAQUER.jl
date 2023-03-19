include("../runtests-prerequisite.jl")

@testset "Test getExactOverlap()" begin

    ContactExposureCtrl.getExactOverlap(
        TRAQUERUtil.nowInTargetTimeZone(), # carrierStartTime::ZonedDateTime,
        missing, # carrierEndTime::Union{Missing, ZonedDateTime}
        TRAQUERUtil.nowInTargetTimeZone(),# contactStartTime::ZonedDateTime,
        missing, # ::Union{Missing, ZonedDateTime},
    ) |> first

end

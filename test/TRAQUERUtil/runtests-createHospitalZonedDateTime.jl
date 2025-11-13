include("prerequisite.jl")

@testset "Test TRAQUERUtil.createHospitalZonedDateTime()" begin

    # Use January 15, 2024 at 10:30 AM (Paris time), which is during standard time (UTC+1)
    # Create the ZonedDateTime using the function and get the equivalent UTC time
    dt = DateTime(2024, 1, 15, 10, 30)
    utc_dt = dt - Hour(1)  # Paris is UTC+1 in January
    zdt = TRAQUERUtil.createHospitalZonedDateTime(dt)
    @test TimeZones.astimezone(zdt, tz"UTC") == ZonedDateTime(utc_dt, tz"UTC")
    TRAQUERUtil.createHZDT(dt) # Test the alias function as well
    createHZDT(dt) # Test that the symbol of the function has been exported correctly
end

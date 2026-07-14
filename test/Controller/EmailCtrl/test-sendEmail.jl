include("__prerequisite.jl")

@testset "Test EmailCtrl.sendEmail" begin

    # Skip the test cleanly when the team address is not configured
    teamEmailAddress = Conf.getTeamEmailAddress()
    if ismissing(teamEmailAddress)
        @info "Skipping EmailCtrl.sendEmail integration test:" *
              " default.team_email_address is not configured"
        return
    end

    @test !ismissing(teamEmailAddress)
    @test teamEmailAddress isa AbstractVector
    @test !isempty(teamEmailAddress)

    # When [email] noemail=true the function short-circuits after logging,
    # which still validates the wiring up to the swaks boundary.
    # When noemail=false it will actually call swaks asynchronously; the
    # @async/try-catch in sendEmail swallows transient send failures so
    # the test passes as long as the function runs without raising.
    EmailCtrl.sendEmail(
        [teamEmailAddress...],
        "EmailCtrl.sendEmail integration test",
        "<p>This message was sent by the EmailCtrl.sendEmail integration test.</p>"
    )

end
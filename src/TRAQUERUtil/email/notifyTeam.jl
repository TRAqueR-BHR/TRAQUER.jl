function TRAQUERUtil.notifyTeam(subject::String,message::String)

    if ismissing(TRAQUERUtil.getTeamEmailAddress())
        return
    end

    TRAQUERUtil.sendemail(
        [TRAQUERUtil.getTeamEmailAddress()...],
        subject,
        message
    )

end

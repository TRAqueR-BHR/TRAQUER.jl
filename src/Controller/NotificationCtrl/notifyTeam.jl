function NotificationCtrl.notifyTeam(
    subject::String,
    message::String
)

    if Conf.slackIsConfigured()
        message = "$subject:\n $message"
        responseSlack = NotificationCtrl.sendSlack(message)
        if responseSlack.status != 200
            @error "Error sending slack message: $responseSlack"
        else
            return
        end
    end

    if ismissing(Conf.getTeamEmailAddress())
        return
    end

    EmailCtrl.sendEmail(
        [Conf.getTeamEmailAddress()...],
        subject,
        message
    )

end
function NotificationCtrl.notifyAdmin(
    subject::String,
    message::String
    ;canNotifyAdminByEmail::Bool = true
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

    if ismissing(Conf.getAdminEmail())
        return
    end

    if canNotifyAdminByEmail
        EmailCtrl.sendEmail(
            [Conf.getAdminEmail()...],
            subject,
            message
        )
    end


end

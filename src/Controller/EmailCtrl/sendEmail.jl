function EmailCtrl.sendEmail(
    recipients::Vector{String},
    subject::String,
    message::String
    ;attachmentFilesPaths::Union{Missing,Vector{String}} = missing
)

    unique!(recipients)

    # Exit if recipients is empty
    if length(recipients) == 0
        return
    end

    if TRAQUERUtil.noEmail()
        @info "Recipients" recipients
        @info "Subject" subject
        @info "Message" message
        @info "Do not send email because 'noemail' is set to true in the configuration."
        return
    end

    # Add signature
    message *= "<br/><br/>"
    message *= "--<br/>"
    message *= getTranslation("do_not_answer_this_email_contact_your_administrator_instead")

    fromaddress = Conf.getEmailFromAddress()
    fromaddressWithName = "$(getInstancePrettyName()) <$fromaddress>"
    replyto = fromaddress
    smtpserver = Conf.getEmailSmtpServer()

    # We loop over the recipients because we sending to multiple recipients in one command
    # does not work
    for recipient in recipients
        cmd = `swaks`
        cmd = TRAQUERUtil.addCmdOption!(cmd, "--to", recipient)
        cmd = TRAQUERUtil.addCmdOption!(cmd, "--from", fromaddress)
        cmd = TRAQUERUtil.addCmdOption!(cmd, "--header", "Subject: $subject")
        cmd = TRAQUERUtil.addCmdOption!(cmd, "--header", "From: $fromaddressWithName")
        cmd = TRAQUERUtil.addCmdOption!(cmd, "--header", "Reply-To: $fromaddressWithName")
        cmd = TRAQUERUtil.addCmdOption!(cmd, "--server", smtpserver)

        if TRAQUERUtil.requiresSMTPAuthentication()
            userid = Conf.getEmailUserid()
            userpwd = Conf.getEmailUserpwd()
            cmd = TRAQUERUtil.addCmdOption!(cmd, "--auth", "LOGIN")
            cmd = TRAQUERUtil.addCmdOption!(cmd, "--auth-user", userid)
            cmd = TRAQUERUtil.addCmdOption!(cmd, "--auth-password", userpwd)
        end

        if TRAQUERUtil.isSendEmailOverTLSConnection()
            cmd = TRAQUERUtil.addCmdOption!(cmd, "--tls", missing)
        end

        # If there are attachments then:
        #   1. Add the files
        #   2. Convert the message to plain text
        #   3. Do not set the content type to html
        if !ismissing(attachmentFilesPaths) && !isempty(attachmentFilesPaths)
            for attachmentFilePath in attachmentFilesPaths
                cmd = TRAQUERUtil.addCmdOption!(cmd, "--attach", "\"@$attachmentFilePath\"")
            end
            message = TRAQUERUtil.htmlToPlainText(message)
        else
            cmd = TRAQUERUtil.addCmdOption!(cmd, "--add-header", "Content-Type: text/html")
        end

        cmd = TRAQUERUtil.addCmdOption!(cmd, "--body", message)


        # We don't want to wait for the email to be sent
        # The try-catch block is not really needed because the @async block already
        #  has the side effect of not making the database transation fail
        @async begin
            try
                run(cmd);
            catch e

                # Dont send email notification to admin if we are already failing at sending
                # him a message
                canNotifyAdminByEmail = if recipient ∈ TRAQUERUtil.getAdminEmail()
                    false
                else
                    true
                end

                formatExceptionAndStackTrace(
                    e,
                    stacktrace(catch_backtrace())
                    ;canNotifyAdminByEmail = canNotifyAdminByEmail
                )
            end
        end

    end

end

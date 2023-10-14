
function TRAQUERUtil.sendemail(
    recipients::Vector{String},
    subject::String,
    message::String
    ;bcc::Bool = false,
     attachmentFilesPaths::Union{Missing,Vector{String}} = missing
)

    unique!(recipients)

    # Exit if recipients is empty
    if length(recipients) == 0
        return
    end

    if TRAQUERUtil.noEmail()
        @info "Do not send email because 'noemail' is set to true in the configuration."
        return
    end

    # Add signature
    message *= "<br/><br/>"
    message *= "--<br/>"
    # message *= getTranslation("do_not_answer_this_email_contact_your_administrator_instead")

    userid = getConf("email","userid")

    fromaddress = "$(TRAQUERUtil.getInstancePrettyName()) <$(getConf("email","from_address"))>"
    replyto = fromaddress
    userpwd = getConf("email","userpwd")
    smtpserver = getConf("email","smtpserver")

    # NOTE: We didn't manage to make this work using a vector of arguments
    #       => fall back to repeating the almost same command with/without
    #          the '-bcc' option
    # options = [
    # "-l email.log",
    # "-f $fromaddress",
    # "-u $subject",
    # "-t $(join(recipients,","))",
    # "-s $smtpserver",
    # "-o tls=yes",
    # "-o message-content-type=html",
    # "-xu $userid",
    # "-xp $userpwd",
    # "-m $message",
    # "-bcc $(TRAQUERUtil.getAdminEmail())"
    # ]

    if bcc

        # Workaround of Amazon AWS not accepting a message with -to recipient
        for bccRecipient in recipients

            @info "bccRecipient[$bccRecipient]"

            sendemailcmd = `sendemail -l email.log
            -f $fromaddress
            -u $subject
            -t $bccRecipient
            -s $smtpserver
            -o tls=yes
            -o message-content-type=html
            -o reply-to=$replyto
            -xu $userid
            -xp $userpwd
            -m $message
            `
            # We don't want to wait for the email to be sent
            # The try-catch block is not really needed because the @async block already
            #  has the side effect of not making the database transation fail
            @async begin
                try
                    run(sendemailcmd);
                catch e
                    formatExceptionAndStackTrace(e,
                                                stacktrace(catch_backtrace()))
                end
            end
        end

    # Not a 'bcc' email
    else

        if ismissing(attachmentFilesPaths)

            sendemailcmd = `sendemail -l email.log
            -f $fromaddress
            -u $subject
            -t $(join(recipients,","))
            -s $smtpserver
            -o tls=yes
            -o message-content-type=html
            -o reply-to=$replyto
            -xu $userid
            -xp $userpwd
            -m $message
            `

            if TRAQUERUtil.bccAdminForEveryEmail()
                sendemailcmd = `sendemail -l email.log
                    -f $fromaddress
                    -u $subject
                    -t $(join(recipients,","))
                    -s $smtpserver
                    -o tls=yes
                    -o message-content-type=html
                    -o reply-to=$replyto
                    -xu $userid
                    -xp $userpwd
                    -m $message
                    -bcc $(TRAQUERUtil.getAdminEmail())
                    `
            end

        else

            sendemailcmd = `sendemail -l email.log
            -f $fromaddress
            -u $subject
            -t $(join(recipients,","))
            -s $smtpserver
            -o tls=yes
            -o message-content-type=html
            -o reply-to=$replyto
            -xu $userid
            -xp $userpwd
            -m $message
            -a $(join(attachmentFilesPaths," "))
            `

            if TRAQUERUtil.bccAdminForEveryEmail()
            sendemailcmd = `sendemail -l email.log
                -f $fromaddress
                -u $subject
                -t $(join(recipients,","))
                -s $smtpserver
                -o tls=yes
                -o message-content-type=html
                -o reply-to=$replyto
                -xu $userid
                -xp $userpwd
                -m $message
                -a $(join(attachmentFilesPaths," "))
                -bcc $(TRAQUERUtil.getAdminEmail())
                `
            end

        end #ENDOF if block on ismissing(attachmentFilesPaths)


        # We don't want to wait for the email to be sent
        # The try-catch block is not really needed because the @async block already
        #  has the side effect of not making the database transation fail
        @async begin
            try
                run(sendemailcmd);
            catch e
                formatExceptionAndStackTrace(e,
                                            stacktrace(catch_backtrace()))
            end
        end


    end

end

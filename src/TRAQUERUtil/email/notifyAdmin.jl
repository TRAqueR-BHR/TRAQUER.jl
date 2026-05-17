function TRAQUERUtil.notifyAdmin(subject::String,message::String)

    if ismissing(TRAQUERUtil.getAdminEmail())
        return
    end

    TRAQUERUtil.sendemail(
        [TRAQUERUtil.getAdminEmail()...],
        subject,
        message
    )

end

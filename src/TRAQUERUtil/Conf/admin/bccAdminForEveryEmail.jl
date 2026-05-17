function Conf.bccAdminForEveryEmail()
    if ismissing(Conf.getAdminEmail())
        return false
    else
        return parse(Bool,Conf.getConf("admin","bcc_admin_for_every_email"))
    end
end

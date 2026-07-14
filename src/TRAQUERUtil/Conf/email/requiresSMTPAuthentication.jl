function Conf.requiresSMTPAuthentication()
    if !Conf.hasConf("email","requires_smtp_authentication")
        return true
    end

    if parse(Bool,Conf.getConf("email","requires_smtp_authentication")) == true
        return true
    else
        return false
    end
end

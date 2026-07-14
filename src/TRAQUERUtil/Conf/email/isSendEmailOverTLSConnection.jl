function Conf.isSendEmailOverTLSConnection()
    if !Conf.hasConf("email","tls")
        return true
    end

    if parse(Bool,Conf.getConf("email","tls")) == true
        return true
    else
        return false
    end
end

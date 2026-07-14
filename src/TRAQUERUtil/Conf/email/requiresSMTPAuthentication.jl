function Conf.requiresSMTPAuthentication()
    return parse(Bool, Conf.getConf("email", "requires_smtp_authentication"))
end
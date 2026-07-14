function Conf.isSendEmailOverTLSConnection()
    return parse(Bool, Conf.getConf("email", "use_tls_connection"))
end
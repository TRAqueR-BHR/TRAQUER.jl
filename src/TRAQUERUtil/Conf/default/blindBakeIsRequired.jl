function Conf.blindBakeIsRequired()
    return parse(Bool,Conf.getConf("default","blind_bake"))
end

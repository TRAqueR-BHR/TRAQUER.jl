function Conf.noEmail()

    if parse(Bool,Conf.getConf("email","noemail")) == true
        return true
    else
        return false
    end

end

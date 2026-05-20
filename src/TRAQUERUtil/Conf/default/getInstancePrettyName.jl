function Conf.getInstancePrettyName()
    prettyName = Conf.getInstanceCodeName()
    prettyName = replace(prettyName,"_" => " ")
    prettyName = uppercase(prettyName)
end

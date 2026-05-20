function Conf.loadConf()::ConfParse

    environment_variable_name = "TRAQUER_CONFIGURATION_FILE"

    if haskey(ENV,environment_variable_name)
        @info "loading configuration file[$(ENV[environment_variable_name])]"
        conf_file = ENV[environment_variable_name]
    else
        throw(DomainError("The application requires the environment"
                          * " variable[$environment_variable_name] to be set."))
    end

    conf = ConfParse(conf_file)
    parse_conf!(conf)
    return(conf)

end

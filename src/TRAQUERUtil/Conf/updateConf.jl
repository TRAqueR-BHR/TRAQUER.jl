function Conf.updateConf()::Bool

    # NOTE: It would be easier to do `parse_conf!(TRAQUER.translation)` but this errors
    #        with SystemError: seek: Illegal seek
    conf = Conf.loadConf()

    # Remove the entries that are no longer in the config. This is needed so that removing
    # a line in the file results in removing the entry in the configuration in memory
    for sectionKey in keys(TRAQUER.config._data)
        for entryKey in keys(TRAQUER.config._data[sectionKey])
            # If the old entry key is not in the new config erase the entry
            if !haskey(conf, sectionKey, entryKey)
                @info "Removing entry [$sectionKey.$entryKey] from configuration"
                ConfParser.erase!(TRAQUER.config,sectionKey, entryKey)
            end
        end
    end

    ConfParser.merge!(TRAQUER.config,conf)

end

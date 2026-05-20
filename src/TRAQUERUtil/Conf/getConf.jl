function Conf.getConf(category_name::AbstractString,property_name::AbstractString)
    ConfParser.retrieve(TRAQUER.config,
                        category_name,
                        property_name)
end

function Conf.hasConf(category_name::AbstractString,property_name::AbstractString)
    ConfParser.haskey(TRAQUER.config,
                        category_name,
                        property_name)
end

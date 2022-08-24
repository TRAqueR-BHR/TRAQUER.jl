function TRAQUERUtil.string2enum(enumType::DataType, str::String)
    PostgresORM.PostgresORMUtil.string2enum(enumType, str)
end

function TRAQUERUtil.string2enum(enumType::DataType, str::Missing)
    return missing
end

function TRAQUERUtil.int2enum(enumType::DataType, int::Integer)
    PostgresORM.PostgresORMUtil.int2enum(enumType, int)
end

function TRAQUERUtil.int2enum(enumType::DataType, int::Missing)
    return missing
end

function TRAQUERUtil.string2number(str::String)
    parse(Float64,str)
end

function TRAQUERUtil.string2number(str::Number)
    return str
end

function TRAQUERUtil.string2type(str::String)
    Meta.parse(str) |> eval
end

function TRAQUERUtil.string2bool(arg::String)
    arg = lowercase(arg)
    if arg == "t" || arg == "true" || arg == "1"
        return true
    elseif arg == "f" || arg == "false" || arg == "0"
        return false
    else
        error("Unable to convert[$arg] to Bool")
    end
end

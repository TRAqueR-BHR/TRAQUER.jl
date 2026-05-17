function TRAQUERUtil.string2enum(enumType::DataType, str::AbstractString)
    PostgresORM.PostgresORMUtil.string2enum(enumType, str)
end

function TRAQUERUtil.string2enum(enumType::DataType, str::Missing)
    return missing
end

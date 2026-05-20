function TRAQUERUtil.listEnums(enumType::DataType
                          ;appuser::Appuser)

    tupleOfEnums = instances(enumType)

    return [tupleOfEnums...]
end

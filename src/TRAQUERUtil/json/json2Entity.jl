function TRAQUERUtil.json2Entity(datatype::DataType,
                     dict::Dict{String,Any})
    dict = PostgresORM.PostgresORMUtil.dictstringkeys2symbol(dict)
    dict = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(dict)
    PostgresORM.Controller.util_dict2entity(
        dict,
        datatype,
        false, # building_from_database_result::Bool,
        false, # retrieve_complex_props::Bool,
        missing #dbconn::Union{LibPQ.Connection,Missing}
             )
end

function TRAQUERUtil.json2entity(
    datatype::Type{Vector{T}},
    arr::Vector{Any}) where T <: IEntity

    entities = T[]
    for dict in arr
        entity = TRAQUERUtil.json2entity(T,dict)
        push!(entities,entity)
    end
    return entities
end

function TRAQUERUtil.json2entity(
    datatype::Type{Vector{T}},
    arr::Missing) where T <: IEntity

    return missing
end

function TRAQUERUtil.json2entity(
    datatype::Type{T},
    dict::Missing) where T <: IEntity
    return missing
end

function TRAQUERUtil.json2entity(
    datatype::Type{T},
    dict::Dict{String,<:Any}) where T <: IEntity

    dict = PostgresORM.PostgresORMUtil.dictstringkeys2symbol(dict)
    dict = PostgresORM.PostgresORMUtil.dictnothingvalues2missing(dict)

    # Fix the Date string according to the timezone
    # "2022-09-01T22:00:00.000Z" -> "2022-09-02"
    for fsymbol in fieldnames(datatype)

        # Get the 'non-missing' type of the property
        ftype = fieldtype(datatype,fsymbol)
        if (typeof(ftype) == Union)
            ftype = PostgresORM.PostgresORMUtil.get_nonmissing_typeof_uniontype(ftype);
        end

        if ftype == Date
            if haskey(dict,fsymbol) && !ismissing(dict[fsymbol])
                dict[fsymbol] = TRAQUERUtil.string2date(
                    dict[fsymbol]
                ) |> string
            end
        end

    end

    PostgresORM.Controller.util_dict2entity(
        dict,
        datatype,
        false, # building_from_database_result::Bool,
        false, # retrieve_complex_props::Bool,
        missing #dbconn::Union{LibPQ.Connection,Missing}
    )
end

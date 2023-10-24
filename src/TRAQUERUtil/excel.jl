function TRAQUERUtil.prepareDataFrameForSerializationToExcel(
    df::DataFrame
    ;translate::Bool = true,
    dropIdColumns::Bool = true
)

    result = deepcopy(df)

    for (i,c) in enumerate(eachcol(result))
        if c isa Vector{ZonedDateTime} || c isa Vector{Union{Missing,ZonedDateTime}}
            result[!,i] = passmissing(DateTime).(result[:,i])
        elseif c isa Vector{<:Base.Enum} || c isa Vector{Union{Missing,T}} where T<:Base.Enum
            if translate
                result[!,i] = passmissing(getTranslation).(result[:,i])
            else
                result[!,i] = passmissing(string).(result[:,i])
            end
        end
    end

    # Rename the columns
    if translate
        rename!(result, Dict(col => getTranslation(string(col)) for col in names(result)))
    end

    # Drop ID columns
    if dropIdColumns
        select!(result, Not([col for col in names(df) if col == "id" || endswith(col, "_id")]))
    end

    return result

end

function TRAQUERUtil.serializeDataFrameToExcel(
    df::DataFrame,
    fullPath::String
)
    XLSX.writetable(
        fullPath,
        TRAQUERUtil.prepareDataFrameForSerializationToExcel(df)
        ;overwrite=true
    )

end

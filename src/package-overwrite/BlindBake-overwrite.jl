using LibPQ, Dates, BlindBake

function BlindBake.invokeMethod(_function::Function, args::Vector, procID::Int64)

    argsTypesForPrinting = join(string.(typeof.(args)),", ")
    @info "Invoke $(_function)($argsTypesForPrinting) on procID[$procID]"

    dbconn::Union{Missing,LibPQ.Connection} = missing
    for arg in args
        if isa(arg,LibPQ.Connection)
            dbconn = arg
        end
    end

    try
        future = @spawnat procID _function(args...)
        fetch(future)
    catch e
        error(e)
    finally
        if !ismissing(dbconn)
            close(dbconn)
        end
    end

end


function BlindBake.createDefaultObject(::Type{LibPQ.Connection})
    return MerchmgtUtil.openDBConnAndBeginTransaction()
end


@everywhere using PostgresORM
function BlindBake.createDefaultObject(::Type{T}) where T<:PostgresORM.IEntity
    return T(id = string(UUIDs.uuid4()))
end

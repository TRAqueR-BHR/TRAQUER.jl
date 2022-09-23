
function TRAQUERUtil.createDBConnAndExecute(fct::Function,args...; kwargs...)

    dbconn = TRAQUERUtil.openDBConn()
    try
        fct(args...,dbconn; kwargs...)
    catch e
        rethrow(e)
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end
end

function TRAQUERUtil.createDBConnAndExecuteWithTransaction(fct::Function,args...; kwargs...)

    dbconn = TRAQUERUtil.openDBConnAndBeginTransaction()
    try
        result = fct(args...,dbconn; kwargs...)
        TRAQUERUtil.commitDBTransaction(dbconn)
        return result
    catch e
        TRAQUERUtil.rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        TRAQUERUtil.closeDBConn(dbconn)
    end
end

# https://richardanaya.medium.com/how-to-create-a-multi-threaded-http-server-in-julia-ca12dca09c35
function TRAQUERUtil.executeOnWorkerTwoOrHigher(fct::Function,args...;kwargs...)

    # Get a worker greater than worker 1
    _procid = if nprocs() > 1
        rand(2:nprocs())
    else
        1
    end

    # res = with_logger(Medilegist.to_file_and_console_logger) do
        res = fetch(@spawnat _procid begin
                fct(args...;kwargs...)
            end)
        # return res
    # end

    # res = fetch(@spawnat _procid do
    #     # with_logger(Medilegist.to_file_and_console_logger) do
    #         fct(args...;kwargs...)
    #     # end
    # end)

    if res isa RemoteException
        throw(res)
    end

    return res
end

# Reference: https://github.com/JuliaWeb/HTTP.jl/issues/798#issuecomment-1019969735
function TRAQUERUtil.executeOnBgThread(fct::Function,args...;kwargs...)

    t = ThreadPools.spawnbg() do
        fct(args...;kwargs...)
    end
    res = fetch(t)

    if res isa CapturedException
        throw(res)
    end

    return res

end

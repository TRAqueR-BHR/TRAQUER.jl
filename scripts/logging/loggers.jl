@everywhere using Logging
@everywhere using Logging: Debug, Info, Warn, Error, BelowMinLevel, with_logger, min_enabled_level

@everywhere using Logging, LoggingExtras

# Give each worker its denux logger
# NOTE: A file logger cannot be shared between workers, the whole content gets overwritten
#         every time a worker writes to it
for _procid in 1:nprocs()
    res = fetch(@spawnat _procid begin

        # Check that the log dir exists
        _dir = joinpath("logs","worker$(_procid)")
        mkpath(_dir)

        date_format = "yyyy-mm-dd HH:MM:SS"
        timestamp_logger(logger) = TransformerLogger(logger) do log
            merge(log, (; message = "$(Dates.format(now(), date_format)) $(log.message)"))
        end


        TeeLogger(
            DatetimeRotatingFileLogger(_dir, raw"\t\r\a\q\u\e\r-YYYY-mm-dd-HH.\l\o\g"),
            ConsoleLogger()
            ) |> timestamp_logger |> global_logger
    end)

    if res isa RemoteException
        throw(res)
    end

end

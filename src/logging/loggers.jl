using Logging
using Logging: Debug, Info, Warn, Error, BelowMinLevel, with_logger, min_enabled_level

using Logging,LoggingExtras

@everywhere to_file_and_console_logger = TeeLogger(
    DatetimeRotatingFileLogger("logs", raw"\t\r\a\q\u\e\r-YYYY-mm-dd-HH.\l\o\g"),
    global_logger()
);

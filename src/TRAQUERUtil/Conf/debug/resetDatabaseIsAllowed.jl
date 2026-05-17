function Conf.resetDatabaseIsAllowed()
    Conf.getConf("debug","allow_database_reset") |>
    n -> parse(Bool, n)
end

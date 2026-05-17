function Conf.getAdminEmail()
    return Conf.getConf("admin","admin_email") |>
        strip |>
        string |>
        n -> split(n,",") |>
        n -> strip.(n) |>
        n -> string.(n) |>
        n -> if isempty(n)  missing else n end
end

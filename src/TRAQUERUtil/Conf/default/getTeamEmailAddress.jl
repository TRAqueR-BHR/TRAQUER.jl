function Conf.getTeamEmailAddress()
    return Conf.getConf("default","team_email_address") |>
        strip |>
        string |>
        n -> split(n,",") |>
        n -> strip.(n) |>
        n -> string.(n) |>
        n -> if isempty(n)  missing else n end
end

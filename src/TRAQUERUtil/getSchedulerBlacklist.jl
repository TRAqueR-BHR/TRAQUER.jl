function TRAQUERUtil.getSchedulerBlacklist()::Vector{String}

    if !TRAQUERUtil.hasConf("scheduler", "blacklist")
        return []
    end

    TRAQUERUtil.getConf("scheduler", "blacklist") |>
    n -> split(n,",") |>
    n -> strip.(n) |>
    n -> string.(n)

end

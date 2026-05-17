function TRAQUERUtil.getTaskWaitingForUserExecutionBlacklist()::Vector{String}

    if !TRAQUERUtil.hasConf("task_waiting_for_user_execution", "blacklist")
        return []
    end

    Conf.getConf("task_waiting_for_user_execution", "blacklist") |>
    n -> split(n,",") |>
    n -> strip.(n) |>
    n -> string.(n)

end

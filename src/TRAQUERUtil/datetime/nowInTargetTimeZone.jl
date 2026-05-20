function TRAQUERUtil.nowInTargetTimeZone()
    now(localzone()) |> # Reminder: 'now' in the computer timezone may be different from the
                        #  hospital timezone, Eg. developers may be working from a different
                        #  timezone than the one configured in the config file
    n -> astimezone(n, Conf.getTimeZone())
end

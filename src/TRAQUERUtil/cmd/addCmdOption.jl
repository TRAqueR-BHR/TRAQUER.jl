function TRAQUERUtil.addCmdOption!(cmd::Cmd, option::String, value::Union{Missing,String})

    if ismissing(value)
        return `$(cmd) $option`
    else
        return `$(cmd) $option $value`
    end

end

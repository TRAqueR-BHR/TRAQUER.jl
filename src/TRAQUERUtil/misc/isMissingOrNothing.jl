function TRAQUERUtil.isMissingOrNothing(x)::Bool
    if ismissing(x)|| isnothing(x)
        return true
    else
        return false
    end
end

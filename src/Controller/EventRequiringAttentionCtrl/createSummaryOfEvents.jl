function EventRequiringAttentionCtrl.createSummaryOfEvents(events::Vector{EventRequiringAttention})::String

    _dict = SplitApplyCombine.group(x -> x.eventType, events)

    resultArr = []
    # TODO: Understand why typeof(v) is EventRequiringAttention and not Vector{EventRequiringAttention}
    # for (k,v) in _dict
    #     @info typeof(v)
    #     # push!(resultArr, "$k -> $(length(v))")
    # end

    result = "<ul>\n"

    for k in keys(_dict)
        v = get(_dict, k, Vector{EventRequiringAttention}())  # Safely retrieve the value
        push!(resultArr, "<li>$(getTranslation(k)) -> $(length(v))</li>")
    end

    result *= join(resultArr, "\n")

    result *= "\n</ul>\n"

    return result

end

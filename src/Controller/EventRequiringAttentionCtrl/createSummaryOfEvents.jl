function EventRequiringAttentionCtrl.createSummaryOfEvents(events::Vector{EventRequiringAttention})::String

    _dict = SplitApplyCombine.group(x -> x.eventType, events)

    @info typeof(_dict)

    resultArr = []
    result = ""

    # TODO: Understand why typeof(v) is EventRequiringAttention and not Vector{EventRequiringAttention}
    # for (k,v) in _dict
    #     @info typeof(v)
    #     # push!(resultArr, "$k -> $(length(v))")
    # end

    for k in keys(_dict)
        v = get(_dict, k, Vector{EventRequiringAttention}())  # Safely retrieve the value
        push!(resultArr, "$(getTranslation(k)) -> $(length(v))")
    end

    join(resultArr, "\n")

end

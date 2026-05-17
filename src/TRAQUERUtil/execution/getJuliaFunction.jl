function TRAQUERUtil.getJuliaFunction(functionNameWithModule::String)::Function

    elts = split(functionNameWithModule,".") |>
    n -> strip.(n) |>
    n -> string.(n)

    functionName = pop!(elts)
    moduleTmp = TRAQUER

    for m in elts

        if m == "TRAQUER"
            continue
        end

        moduleTmp = getfield(moduleTmp, Symbol(m))

    end

    fct = getfield(moduleTmp, Symbol(functionName))

end

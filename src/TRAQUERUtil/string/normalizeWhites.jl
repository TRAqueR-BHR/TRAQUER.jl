function TRAQUERUtil.normalizeWhites(str::AbstractString, keepLineReturns::Bool)

    if keepLineReturns
        result = TRAQUERUtil.removeDoubleSpaces(str) |>
                 n -> TRAQUERUtil.removeDoubleLineReturns(n)
    else
        result = replace(str, r"\s" => " ") |> # Replace all spaces (including line
                                                  #   returns) by a space
                 n -> TRAQUERUtil.removeDoubleSpaces(n)
    end

    return result
end

function TRAQUERUtil.removeDoubleLineReturns(str)
    result = str |> n -> replace(n,r"[\ \f\t\n]*[\n\r]+[\ \f\t\n]*" => "\n") |>
                    n -> (string∘strip)(n)
    return result
end

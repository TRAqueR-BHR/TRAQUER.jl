function TRAQUERUtil.removeDoubleSpaces(str)

    result = str |> n -> replace(n, r"\u00a0" => " ") |> # Replace NBSP by a normal space
                    n -> replace(n,r"[\ \f\t]{2,}" => " ") |>
                    n -> (string∘strip)(n)
    return result
end

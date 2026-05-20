function TRAQUERUtil.cleanStringForEncryptedValueCp(str)
    result = TRAQUERUtil.rmAccentsAndLowercase(str) |>
             n -> TRAQUERUtil.normalizeWhites(n,
                                             # replace line returns by spaces
                                             true) |>
             strip |> string |>
             n -> replace(n, r"[[:punct:]]" => "")
    result
end

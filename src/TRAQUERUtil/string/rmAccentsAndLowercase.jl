function TRAQUERUtil.rmAccentsAndLowercase(str::AbstractString)
    return Unicode.normalize(str,stripmark=true) |>
           n -> lowercase(n)
end

using ConfParser

# Tweak the following
# Do not stop at first whitespace
# Do not consider ',' as a separator (needed for translation file)
function ConfParser.parse_line(line::String)
    line = string(strip(line)) |>
        n -> string.(n) |>
        n -> replace.(n, "`" => "'")
    return [line]
end


# function ConfParser.parse_line(line::String)
#     parsed   = String[]
#     splitted = split(line, ",")
#     for raw = splitted
#         if occursin(r"\S+", raw)
#             clean = match(r"\S+", raw)
#             push!(parsed, clean.match)
#         end
#     end
#     @info "typeof(parsed)[$(typeof(parsed))]"
#     parsed
# end

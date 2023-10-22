using ConfParser

# Tweak the following:
# 1. Do not stop at first whitespace
# 2. Do not consider ',' as a separator (needed for translation file). Implement split if
#    needed in the functions that use the config eg. TRAQUERUtil.getAdminEmail()
function ConfParser.parse_line(line::String)
    line = string(strip(line)) |>
        n -> string.(n) |>
        n -> replace.(n, "`" => "'")
    return [line]
end

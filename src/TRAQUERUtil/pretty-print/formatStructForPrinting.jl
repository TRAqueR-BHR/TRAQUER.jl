function TRAQUERUtil.formatStructForPrinting(o)::String
    io = IOBuffer()
    PrettyPrint.pprintln(io,o)
    String(take!(io))
end
